BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1').Replace('\Test\', '\Source\').Replace('/Test/', '/Source/')
}

Describe 'Invoke-GitHubRequest' {
    Context 'Parameters' {
        It 'Should have mandatory Method and Target parameters' {
            $function = Get-Command 'Invoke-GitHubRequest'
            $function | Should -HaveParameter 'Method' -Mandatory
            $function | Should -HaveParameter 'Target' -Mandatory
        }
        It 'Should have optional Body parameter' {
            $function = Get-Command 'Invoke-GitHubRequest'
            $function | Should -HaveParameter 'Body' -Not -Mandatory
            $function | Should -HaveParameter 'Body' -Type 'System.Collections.IDictionary'
        }
    }
}