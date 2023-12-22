function Invoke-GitHubRequest {
    [CmdletBinding()]
    param (
        # Action
        [Parameter(Mandatory=$true,Position=0)]
        [ValidateSet('GET', 'PATCH', 'DELETE', 'POST')]
        [string]
        $Method,

        # Target
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        $Target,

        # Other parameters
        [Parameter()]
        [System.Collections.IDictionary]
        $Body,

        # Request only
        [Parameter()]
        [switch]
        $RequestOnly = $false
    )

    # TODO: Convert GitHub result data, where there is any, from snake case to Pascal case, which is more PowerShelly.  But maybe it isn't worth the effort for an exclusively learning project.

    $isVerbose = $VerbosePreference -eq 'Continue'

    if (-not $Script:Connection) {
        throw "No GitHub connection found.  Please use Connect-GitHub to connect to GitHub and try again."
    }

    $headersToRedact = @(
        'Authorization'
    )

    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Script:Connection.PersonalAccessToken)
    $pat = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    $headers = @{
        Accept = "application/vnd.github+json"
        Authorization = "Bearer $($pat)"
        "X-GitHub-Api-Version" = $Script:Connection.APIVersion
    }
    $uri = "$($Script:Connection.ServerAddress)/$Target"

    $invokeParameters = @{
        Uri = $uri
        Headers = $headers
        Method = $Method
        Verbose = $isVerbose
    }

    Write-Verbose "Using URI [$($invokeParameters.Uri)]"
    Write-Verbose "Using method [$($invokeParameters.Method)]"
    Write-Verbose "Using headers:"
    $invokeParameters.Headers.GetEnumerator() | `
        ForEach-Object {if ($_.Key -in $headersToRedact) {[System.Collections.DictionaryEntry]::new($_.Key, '[R*e*D*a*C*t*E*d]')} else {$_}} | `
        ForEach-Object {"    $($_.Key):  $($_.Value)"} | `
        Write-Verbose
    if ($Body) {
        Write-Verbose "Using body:"
        $Body.Keys | `
            ForEach-Object {"    $($_):  $($Body[$_])"} | `
            Write-Verbose
        $invokeParameters['Body'] = $Body | ConvertTo-Json
        $invokeParameters['ContentType'] = 'application/json'
    }

    if ($RequestOnly) {
        $invokeParameters
    } else {
        try {
            $response = Invoke-WebRequest @invokeParameters
            $response | Format-List -Property StatusCode, StatusDescription, RawContentLength | Out-String | Write-Verbose
            $response | ConvertFrom-Json
        } catch {
            $_.Exception.Response.ReasonPhrase | Add-Member -PassThru -NotePropertyName StatusCode -NotePropertyValue $_.Exception.Response.StatusCode
        }
    }
}