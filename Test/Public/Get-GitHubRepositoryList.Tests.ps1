BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1').Replace('\Test\', '\Source\').Replace('/Test/', '/Source/')
    . $PSScriptRoot\..\..\Source\Private\Invoke-GitHubRequest.ps1
    Mock Invoke-GitHubRequest {}
}

Describe 'Get-GitHubRepositoryList' {
    Context 'Parameters' {
        It 'Has parameters' {
            $function = Get-Command Get-GitHubRepositoryList
            $function | Should -HaveParameter 'Owner'
        }
    }
    Context 'Url' {
        It 'Uses the Get method'{
            Get-GitHubRepositoryList -Owner 'Waldo'
            Should -Invoke 'Invoke-GitHubRequest' -ParameterFilter {$Method -eq 'GET'}
        }
        It 'Uses the correct Target'{
            Get-GitHubRepositoryList -Owner 'Waldo'
            Should -Invoke 'Invoke-GitHubRequest' -ParameterFilter {$Target -eq 'users/Waldo/repos'}
        }
    }
}