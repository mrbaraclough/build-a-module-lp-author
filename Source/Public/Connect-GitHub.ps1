function Connect-GitHub {
    [CmdletBinding()]
    param (
        # Personal access token
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        $personalAccessToken
    )

    $Script:Connection = @{
        PersonalAccessToken = (ConvertTo-SecureString -String $personalAccessToken -AsPlainText -Force)
        ServerAddress = 'https://api.github.com'
        APIVersion = '2022-11-28'
    }
}