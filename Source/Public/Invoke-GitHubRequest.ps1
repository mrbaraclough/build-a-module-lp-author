function Invoke-GitHubRequest {
    [CmdletBinding()]
    param (
        # Owner
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        $Owner,

        # Repository
        [Parameter(Mandatory=$true,Position=1)]
        [string]
        $Repository,

        # Action
        [Parameter(Mandatory=$true,Position=2)]
        [ValidateSet('GET', 'PATCH', 'DELETE', 'POST')]
        [string]
        $Method,

        # Other parameters
        [Parameter()]
        [hashtable]
        $Body
    )

    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Script:Connection.PersonalAccessToken)
    $pat = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    $headers = @{
        Accept = "application/vnd.github+json"
        Authorization = "Bearer $($pat)"
        "X-GitHub-Api-Version" = $Script:Connection.APIVersion
    }
    $uri = "$($Script:Connection.ServerAddress)/repos/$Owner/$Repository"

    $invokeParameters = @{
        Uri = $uri
        Headers = $headers
        Method = $Method
    }

    if ($Body) {
        $invokeParameters['Body'] = $Body
        $invokeParameters['ContentType'] = 'application/json'
    }

    Invoke-RestMethod @invokeParameters
}