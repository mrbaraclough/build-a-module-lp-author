BeforeAll {
    . ($PSCommandPath.Replace('.Tests.ps1', '.ps1').Replace('\Test\', '\Source\'))
    . $PSScriptRoot\..\..\Source\Private\Invoke-GitHubRequest.ps1
    Mock Invoke-GitHubRequest {}
}

Describe 'New-GitHubRepository' {
    Context 'Parameters' {
        It 'Should have Owner and Repository parameters' {
            $function = Get-Command 'New-GitHubRepository'
            $function | Should -HaveParameter 'Owner' -Mandatory
            $function | Should -HaveParameter 'Repository' -Mandatory
        }
        It 'Should have optional Description and Private paremeters' {
            $function = Get-Command 'New-GitHubRepository'
            $function | Should -HaveParameter 'Description' -Not -Mandatory
            $function | Should -HaveParameter 'Description' -Type 'System.String'
            $function | Should -HaveParameter 'Private' -Not -Mandatory
            $function | Should -HaveParameter 'Private' -Type 'System.Boolean'
        }
    }
    Context 'URL' {
        It 'Uses POST method' {
            New-GitHubRepository -Force -Owner 'Waldo' -Repository 'Waldo-Repository'
            Should -Invoke 'Invoke-GitHubRequest' -ParameterFilter {$Method -eq 'POST'}
        }
        It 'Uses the correct target' {
            New-GitHubRepository -Force -Owner 'Waldo' -Repository 'Waldo-Repository'
            Should -Invoke 'Invoke-GitHubRequest' -ParameterFilter {$Target -eq 'user/repos'}
        }
        It 'Includes the repository name' {
            New-GitHubRepository -Force -Owner 'Waldo' -Repository 'Waldo-Repository'
            Should -Invoke 'Invoke-GitHubRequest' -ParameterFilter {$Body.Keys -contains 'name' -and $Body['name'] -eq 'Waldo-Repository'}
        }
    }
}