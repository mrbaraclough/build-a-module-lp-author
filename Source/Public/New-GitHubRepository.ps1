function New-GitHubRepository {
    [CmdletBinding()]
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
        [string]$SquashMergeCommitTitle = "PR_TITLE",

        [ValidateSet('PR_BODY', 'COMMIT_MESSAGES', 'BLANK')]
        [string]$SquashMergeCommitMessage = "PR_BODY",

        [ValidateSet('PR_TITLE', 'MERGE_MESSAGE')]
        [string]$MergeCommitTitle = "PR_TITLE",

        [ValidateSet('PR_TITLE', 'PR_BODY', 'BLANK')]
        [string]$MergeCommitMessage = "PR_TITLE",

        [bool]$HasDownloads = $true,

        [bool]$IsTemplate = $false
    )

    # Populeate Body
    # Populate Body
    $body = @{}

    # Invoke
    Invoke-GitHubRequest -Owner $Owner -Repository $Repository -Method 'POST' -Body $body
}