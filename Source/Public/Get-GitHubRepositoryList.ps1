function Get-GitHubRepositoryList {
    [CmdletBinding()]
    param (
        # Owner
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        $Owner,

        # Request only
        [Parameter()]
        [switch]
        $RequestOnly = $false
    )

    $isVerbose = $VerbosePreference -eq 'Continue'
    Invoke-GitHubRequest -Method 'GET' -Target "users/$Owner/repos" -RequestOnly:$RequestOnly -Verbose:$isVerbose
}
