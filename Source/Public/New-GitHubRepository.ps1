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