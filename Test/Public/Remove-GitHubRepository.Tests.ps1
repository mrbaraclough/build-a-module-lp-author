BeforeAll {
    . ($PSCommandPath.Replace('.Tests.ps1', '.ps1').Replace('\Test\', '\Source\').Replace('/Test/', '/Source/'))
    . $PSScriptRoot\..\..\Source\Private\Invoke-GitHubRequest.ps1
    Mock Invoke-GitHubRequest {}
}

Describe 'Remove-GitHubRepository' {
    Context 'Parameters' {
        It 'Has Owner and Repository parameters' {
            $function = Get-Command Remove-GitHubRepository
            $function | Should -HaveParameter 'Owner'
            $function | Should -HaveParameter 'Repository'
        }
    }
    Context 'URL' {
        It 'Uses POST method' {
            Remove-GitHubRepository -Force -Owner 'Waldo' -Repository 'Waldo-Repository'
            Should -Invoke 'Invoke-GitHubRequest' -ParameterFilter {$Method -eq 'DELETE'}
        }
        It 'Uses the correct target' {
            Remove-GitHubRepository -Force -Owner 'Waldo' -Repository 'Waldo-Repository'
            Should -Invoke 'Invoke-GitHubRequest' -ParameterFilter {$Target -eq 'repos/Waldo/Waldo-Repository'}
        }
    }
}