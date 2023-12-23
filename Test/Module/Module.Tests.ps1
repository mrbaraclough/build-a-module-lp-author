param (
    [Parameter(Mandatory=$true,Position=0)]
    [SecureString]
    $PersonalAccessToken
)

BeforeAll {
    Import-Module -Name "$PSScriptRoot\..\..\Output\Rocinante.GitHub\1.0.0\Rocinante.GitHub.psd1"
    $owner = 'mrbaraclough'
    $testRepoName = [System.Guid]::NewGuid().ToString().Replace('-', '')
    $description = 'a happy test repo'
    $description2 = 'a very happy test repo'
    Write-Host "Test repository name:  [$testRepoName]"
}

Describe 'Rocinante.GitHib Module Integration Tests' {
    It 'Can connect to GitHub' {
        Connect-GitHub -PersonalAccessToken $PersonalAccessToken -Verbose 4>&1
    }
    It 'Can check for a repository' {
        $repo = Get-GitHubRepository -Owner $owner -Repository $testRepoName
        [int]$repo.StatusCode | Should -Be 404
    }
    It 'Can create a repository' {
        $repo = New-GitHubRepository -Owner $owner -Repository $testRepoName -Description $description -Force
        $repo.name | Should -Be $testRepoName
        $repo.description | Should -Be $description
        Start-Sleep -Seconds 5
    }
    It 'Can get a repository' {
        $repo = Get-GitHubRepository -Owner $owner -Repository $testRepoName
        $repo | Should -Not -Be $null
        $repo.name | Should -Be $testRepoName
        $repo.private | Should -Be $false
        $repo.description | Should -Be $description
    }
    It 'Can update a repository' {
        $repo = Update-GitHubRepository -Owner $owner -Repository $testRepoName -Description $description2 -Force
        $repo.name | Should -Be $testRepoName
        $repo.description | Should -Be $description2
    }
    It 'Can update a repository and the updates persist' {
        $repo = Get-GitHubRepository -Owner $owner -Repository $testRepoName
        $repo.name | Should -Be $testRepoName
        $repo.description | Should -Be $description2
    }
    It 'Can delete a repository' {
        Remove-GitHubRepository -Owner $owner -Repository $testRepoName -Force
        Start-Sleep -Seconds 5
        $repo = Get-GitHubRepository -Owner $owner -Repository $testRepoName
        [int]$repo.StatusCode | Should -Be 404
    }
}
