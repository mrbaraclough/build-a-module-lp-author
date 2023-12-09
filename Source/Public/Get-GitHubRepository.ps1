function Get-GitHubRepository {
<#
.SYNOPSIS
    Gets the specified GitHub repository.
.DESCRIPTION
    Get-GitHubRepository gets the GitHub repository specified by the owner and repository name.
.EXAMPLE
    Get-GitHubRepository -Owner joeGitHub -Repository HelloWorld

    Returns the HelloWorld GitHub repository belonging to user joeGitHub.
#>
    [CmdletBinding()]
    param (
        # Owner
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        $Owner,

        # Repository
        [Parameter(Mandatory=$true,Position=1)]
        [Alias('Name')]
        [string]
        $Repository
    )

    $isVerbose = $VerbosePreference -eq 'Continue'
    Invoke-GitHubRequest -Method 'GET' -Target "repos/$Owner/$Repository" -Verbose:$isVerbose
}