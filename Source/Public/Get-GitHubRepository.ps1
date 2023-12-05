function Get-GitHubRepository {
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
    Invoke-GitHubRequest -Owner $Owner -Repository $Repository -Method 'GET'
}