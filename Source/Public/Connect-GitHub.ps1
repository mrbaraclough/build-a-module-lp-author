function Connect-GitHub {
<#
.SYNOPSIS
    Connects to GitHub using the provided personal access token.
.DESCRIPTION
    Uses provided personal access token to create an ambient authentication values for use by other Rocinante.GitHub functions.
.EXAMPLE
    Connect-GitHub -PersonalAccessToken (ConvertTo-SecureString -String 'github_pat_1234567890BOGUSTOKEN0987654321') -Cache

    Connects to GitHub with the provided personal access token and caches the token.
.EXAMPLE
    Connect-GitHub

    Connects to GitHub using the cached personal access token.
.EXAMPLE
    Connect-GitHub -PersonalAccessToken (ConvertTo-SecureString -String 'github_pat_1234567890BOGUSTOKEN0987654321')

    Connects to GitHub with the provided personal access token.
#>
    [CmdletBinding(DefaultParameterSetName='UseCache')]
    param (
        # GitHub personal access token.
        [Parameter(ParameterSetName='WriteCache',Mandatory=$true,Position=0)]
        [Parameter(ParameterSetName='UseCache',Mandatory=$false,Position=0)]
        [SecureString]
        $PersonalAccessToken,

        # Cache GitHub personal access token.
        [Parameter(ParameterSetName='WriteCache')]
        [switch]
        $Cache = $false
    )

    $cacheDirectory = [IO.Path]::Combine($Env:LOCALAPPDATA, 'Rocinante.GitHub')
    $patCachePath = [IO.Path]::Combine($cacheDirectory, 'pat.xml')

    if ($Cache) {
        Write-Verbose "Using cache directory [$cacheDirectory]."
        $exists = Test-Path -Path $cacheDirectory -PathType Container
        if (-not $exists) {
            Write-Verbose "Creating cache directory [$cacheDirectory]."
            New-Item -Path $cacheDirectory -ItemType Directory | Out-Null
        }
        Write-Verbose "Caching personal access token in [$patCachePath]."
        $PersonalAccessToken | Export-Clixml -Path $patCachePath
    }

    if (-not $PersonalAccessToken) {
        $patCacheExists = Test-Path -Path $patCachePath -PathType Leaf
        if (-not $patCacheExists) {
            throw "No personal access token provided and no cached token found at [$patCachePath]"
        }
        Write-Verbose "Using cached personal access tokey [$patCachePath]."
        $PersonalAccessToken = Import-Clixml -Path $patCachePath
    }

    $Script:Connection = @{
        PersonalAccessToken = $PersonalAccessToken
        ServerAddress = 'https://api.github.com'
        APIVersion = '2022-11-28'
    }

    Write-Verbose "Using ServerAddress [$($Script:Connection.ServerAddress)]."
    Write-Verbose "Using APIVersion [$($Script:Connection.APIVersion)]."
}