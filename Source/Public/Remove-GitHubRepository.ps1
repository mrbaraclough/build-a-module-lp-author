function Remove-GitHubRepository
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
        $Repository
    )

    if ($PSCmdlet.ShouldProcess("$Owner/$Repository", "Delete repository")) {
        Invoke-GitHubRequest -Owner $Owner -Repository $Repository -Method 'DELETE'
    }
}