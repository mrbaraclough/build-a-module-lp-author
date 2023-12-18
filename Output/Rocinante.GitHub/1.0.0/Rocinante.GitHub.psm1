#Region './Private/Invoke-GitHubRequest.ps1' 0
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
        $Body
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

    Invoke-RestMethod @invokeParameters
}
#EndRegion './Private/Invoke-GitHubRequest.ps1' 68
#Region './Public/Connect-GitHub.ps1' 0
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
#EndRegion './Public/Connect-GitHub.ps1' 66
#Region './Public/Get-GitHubRepository.ps1' 0
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
#EndRegion './Public/Get-GitHubRepository.ps1' 29
#Region './Public/New-GitHubRepository.ps1' 0
function New-GitHubRepository {
<#
.SYNOPSIS
    Creates new GitHub repositories.
.DESCRIPTION
    New-GitHubRepository creates new GitHub repositories for the specified user.
.EXAMPLE
    New-GitHubRepository -vb -Owner 'joeGitHub -Repository 'HelloWorld' -Description 'Hello World repository'

    Creates a new repository for user joeGitHub named HelloWorld.
#>
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
    param (
        # Owner
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        $Owner,

        # Repository name
        [Parameter(Mandatory=$true,Position=1)]
        [Alias('Name')]
        [string]
        $Repository,

        [string]$Description,
        [string]$Homepage,
        [bool]$Private = $false,
        [bool]$HasIssues = $true,
        [bool]$HasProjects = $true,
        [bool]$HasWiki = $true,
        [bool]$HasDiscussions = $false,
        [int]$TeamId,
        [bool]$AutoInit = $false,
        [string]$GitignoreTemplate,
        [string]$LicenseTemplate,
        [bool]$AllowSquashMerge = $true,
        [bool]$AllowMergeCommit = $true,
        [bool]$AllowRebaseMerge = $true,
        [bool]$AllowAutoMerge = $false,
        [bool]$DeleteBranchOnMerge = $false,

        [ValidateSet('PR_TITLE', 'COMMIT_OR_PR_TITLE')]
        [string]$SquashMergeCommitTitle,

        [ValidateSet('PR_BODY', 'COMMIT_MESSAGES', 'BLANK')]
        [string]$SquashMergeCommitMessage,

        [ValidateSet('PR_TITLE', 'MERGE_MESSAGE')]
        [string]$MergeCommitTitle,

        [ValidateSet('PR_TITLE', 'PR_BODY', 'BLANK')]
        [string]$MergeCommitMessage,

        [bool]$HasDownloads = $true,
        [bool]$IsTemplate = $false,

        # Force
        [switch]
        $Force = $false
    )

    $isVerbose = $VerbosePreference -eq 'Continue'

    # Populate Body
    $body = [ordered]@{
        name = $Repository
        private = $Private
        has_issues = $HasIssues
        has_projects = $HasProjects
        has_wiki = $HasWiki
        has_discussions = $HasDiscussions
        auto_init = $AutoInit
        allow_squash_merge = $AllowSquashMerge
        allow_Merge_commit = $AllowMergeCommit
        allow_rebase_merge = $AllowRebaseMerge
        allow_auto_merge = $AllowAutoMerge
        deleteBranchOnMerge = $DeleteBranchOnMerge
        has_downloads = $HasDownloads
        is_template = $IsTemplate
    }

    if ($Description) { $body['description'] = $Description}
    if ($Homepage) { $body['homepage'] = $Homepage}
    if ($TeamId) { $body['team_id'] = $TeamId}
    if ($GitignoreTemplate) { $body['gitignore_template'] = $GitignoreTemplate}
    if ($LicenseTemplate) { $body['license_template'] = $LicenseTemplate}
    if ($SquashMergeCommitTitle) { $body['squash_merge_commit_title'] = $SquashMergeCommitTitle }
    if ($SquashMergeCommitMessage) { $body['squash_merge_commit_message'] = $SquashMergeCommitMessage }
    if ($MergeCommitTitle) { $body['merge_commit_title'] = $MergeCommitTitle }
    if ($MergeCommitMessage) { $body['merge_commit_message'] = $MergeCommitMessage }

    if ($Force -or $PSCmdlet.ShouldProcess("GitHub user [$Owner]", "Create new GitHub repository [$Repository]")) {
        Invoke-GitHubRequest -Method 'POST' -Target "user/repos" -Body $body -Verbose:$isVerbose
    }
}
#EndRegion './Public/New-GitHubRepository.ps1' 96
#Region './Public/Remove-GitHubRepository.ps1' 0
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
#EndRegion './Public/Remove-GitHubRepository.ps1' 37
#Region './Public/Update-GitHubRepository.ps1' 0
function Update-GitHubRepository {
<#
.SYNOPSIS
    Updates a GitHub repository attributes.
.DESCRIPTION
    Update-GitHubRepository updates a GitHub repository's attributes.
.EXAMPLE
    Update-GitHubRepository -Owner joeGitHub -Repository 'HelloWorld' -Description 'This is the updated repository description'

    Updates the description of the HelloWorld repository belonging to joeGitHub.
#>
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

        [string]$Description,
        [string]$Homepage,
        [switch]$Private = $false,

        [bool]$HasIssues = $true,
        [bool]$HasProjects = $true,
        [bool]$HasWiki = $true,
        [bool]$IsTemplate = $false,
        [string]$DefaultBranch,
        [bool]$AllowSquashMerge = $true,
        [bool]$AllowMergeCommit = $true,
        [bool]$AllowRebaseMerge = $true,
        [bool]$AllowAutoMerge = $false,
        [bool]$DeleteBranchOnMerge = $false,
        [bool]$AllowUpdateBranch = $false,
        [bool]$UseSquashPrTitleAsDefault = $false,

        [ValidateSet('PR_TITLE', 'COMMIT_OR_PR_TITLE')]
        [string]$SquashMergeCommitTitle,

        [ValidateSet('PR_BODY', 'COMMIT_MESSAGES', 'BLANK')]
        [string]$SquashMergeCommitMessage,

        [ValidateSet('PR_TITLE', 'NERGE_MESSAGE')]
        [string]$MergeCommitTitle,

        [ValidateSet('PR_TITLE', 'PR_BODY', 'BLANK')]
        [string]$MergeCommitMessage,

        [bool]$Archived = $false,
        [bool]$WebCommitSignoffRequired = $false,

        # Force
        [switch]
        $Force = $false
    )

    # TODO: Add security_and_analysis parameter.  But I'm not sure it's work the effort for a learning project.
    # TODO: Rework [bool] parameters into legit PowerShell [switch] parameters that default to false.  E.g., SuppressIssues instead of HasIssues.

    $isVerbose = $VerbosePreference -eq 'Continue'

    # Populate Body
    $body = [ordered]@{
        name = $Repository
        private = $Private
        has_issues = $HasIssues
        has_projects = $HasProjects
        has_wiki = $HasWiki
        is_template = $IsTemplate
        allow_squash_merge = $AllowSquashMerge
        allow_merge_commit = $AllowMergeCommit
        allow_rebase_merge = $AllowRebaseMerge
        allow_auto_merge = $AllowAutoMerge
        delete_branch_on_merge = $DeleteBranchOnMerge
        allow_update_branch = $AllowUpdateBranch
        use_squash_pr_title_as_default = $UseSquashPrTitleAsDefault
        archived = $Archived
        web_commit_signoff_required = $WebCommitSignoffRequired
    }

    if ($Description) { $body['description'] = $Description}
    if ($Homepage) { $body['homepage'] = $Homepage}
    if ($DefaultBranch) { $body['default_branch'] = $DefaultBranch}
    if ($SquashMergeCommitTitle) { $body['squash_merge_commit_title'] = $SquashMergeCommitTitle}
    if ($SquashMergeCommitMessage) { $body['squash_merge_commit_message'] = $SquashMergeCommitMessage}
    if ($MergeCommitTitle) { $body['merge_commit_title'] = $MergeCommitTitle}
    if ($MergeCommitMessage) { $body['merge_commit_message'] = $MergeCommitMessage}

    if ($Force -or $PSCmdlet.ShouldProcess("GitHub user [$Owner]", "Update GitHub repository [$Repository]")) {
        Invoke-GitHubRequest -Method 'PATCH' -Target "repos/$Owner/$Repository" -Body $body -Verbose:$isVerbose
    }
}
#EndRegion './Public/Update-GitHubRepository.ps1' 98
