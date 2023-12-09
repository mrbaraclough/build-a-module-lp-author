function Remove-GitHubRepository
<#
.SYNOPSIS
    Deletes the specified GitHub repository.
.DESCRIPTION
    Remove-GitHubRepository deletes the specified GitHub repository for the specified user.
.EXAMPLE
    Remove-GitHubRepository -Owner joeGitHub -Repository HelloWorld

    Delete's the HelloWorld repository belonging to joeGitHub.
#>
{
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
    param (
        # Owner
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        $Owner,

        # Repository
        [Parameter(Mandatory=$true,Position=1)]
        [Alias('Name')]
        [string]
        $Repository,

        # Force
        [switch]
        $Force = $false
    )

    $isVerbose = $VerbosePreference -eq 'Continue'

    if ($Force -or $PSCmdlet.ShouldProcess("$Owner/$Repository", "Delete repository")) {
        Invoke-GitHubRequest -Method 'DELETE' -Target "repos/$Owner/$Repository" -Verbose:$isVerbose
    }
}