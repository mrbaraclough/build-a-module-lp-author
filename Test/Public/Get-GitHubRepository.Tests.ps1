BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1').Replace('\Test\', '\Source\')
    . $PSScriptRoot\..\..\Source\Private\Invoke-GitHubRequest.ps1
    Mock Invoke-GitHubRequest {}
}

Describe 'Get-GitHubRepository' {
    Context 'Parameters' {
        It 'Has parameters' {
            $function = Get-Command Get-GitHubRepository
            $function | Should -HaveParameter 'Owner'
            $function | Should -HaveParameter 'Repository'
        }
    }
    Context 'Url' {
        It 'Uses the Get method'{
            Get-GitHubRepository -Owner 'Waldo' -Repository 'Waldo-Repository'
            Should -Invoke 'Invoke-GitHubRequest' -ParameterFilter {$Method -eq 'GET'}
        }
        It 'Uses the correct Target'{
            Get-GitHubRepository -Owner 'Waldo' -Repository 'Waldo-Repository'
            Should -Invoke 'Invoke-GitHubRequest' -ParameterFilter {$Target -eq 'repos/Waldo/Waldo-Repository'}
        }
    }
}