BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1').Replace('\Test\', '\Source\')
    . $PSScriptRoot\..\..\Source\Private\Invoke-GitHubRequest.ps1
    Mock Invoke-GitHubRequest {}
}

Describe 'Update-GitHubRepository' {
    Context 'Parameters' {
        It "Has Owner and Repository parameters" {
            $function = Get-Command Update-GitHubRepository
            $function | Should -HaveParameter 'Owner'
            $function | Should -HaveParameter 'Repository'
        }
        It 'Has other parameters' {
            $function = Get-Command Update-GitHubRepository
            $function | Should -HaveParameter 'Description'
            $function | Should -HaveParameter 'DefaultBranch'
            $function | Should -HaveParameter 'Private'
            $function.Parameters['Private'].ParameterType.Name | Should -Be 'SwitchParameter'
        }
        It 'Converts HasIssues parameter to snake case in the Body hashtable' {
            Update-GitHubRepository -Force -Owner 'Waldo' -Repository 'Waldo-Repository' -HasIssues:$false
            Should -Invoke 'Invoke-GitHubRequest' -ParameterFilter {$Body.Keys -contains 'has_issues' -and $Body.has_issues -eq $false}
        }
        It 'Converts HasProjects parameter to snake case in the Body hashtable' {
            Update-GitHubRepository -Force -Owner 'Waldo' -Repository 'Waldo-Repository' -HasProjects:$false
            Should -Invoke 'Invoke-GitHubRequest' -ParameterFilter {$Body.Keys -contains 'has_projects' -and $Body.has_projects -eq $false}
        }
        It 'Converts default parameters to snake case in the Body hashtable' {
            Update-GitHubRepository -Force -Owner 'Waldo' -Repository 'Waldo-Repository'
            $defaultValueParams = @(
                'has_issues'
                'has_projects'
                'has_wiki'
                'is_template'
                'allow_squash_merge'
                'allow_merge_commit'
                'allow_rebase_merge'
                'allow_auto_merge'
                'delete_branch_on_merge'
                'allow_update_branch'
                'use_squash_pr_title_as_default'
                'web_commit_signoff_required'
            )

            Should -Invoke 'Invoke-GitHubRequest' -ParameterFilter {
                @($defaultValueParams | ForEach-Object -Process {$Body.Keys -contains $_}) -notcontains $false
            }
        }
    }
    Context 'Url' {
        It 'Uses the PATCH method' {
            Update-GitHubRepository -Force -Owner 'Waldo' -Repository 'Waldo-Repository'
            Should -Invoke 'Invoke-GitHubRequest' -ParameterFilter {$Method -eq 'PATCH'}
        }
        It 'Constructs the correct target' {
            Update-GitHubRepository -Force -Owner 'Waldo' -Repository 'Waldo-Repository' -Description 'The Waldo Repository' -Verbose
            Should -Invoke 'Invoke-GitHubRequest' -ParameterFilter {$Target -eq "repos/Waldo/Waldo-Repository"}
        }
    }
}