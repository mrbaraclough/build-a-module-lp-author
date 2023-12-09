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
        [bool]$Private = $false,

        [ValidateSet("public", "private")]
        [string]$Visibility,

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
    if ($Visibility) { $body['visibility'] = $Visibility}
    if ($DefaultBranch) { $body['default_branch'] = $DefaultBranch}
    if ($SquashMergeCommitTitle) { $body['squash_merge_commit_title'] = $SquashMergeCommitTitle}
    if ($SquashMergeCommitMessage) { $body['squash_merge_commit_message'] = $SquashMergeCommitMessage}
    if ($MergeCommitTitle) { $body['merge_commit_title'] = $MergeCommitTitle}
    if ($MergeCommitMessage) { $body['merge_commit_message'] = $MergeCommitMessage}

    if ($Force -or $PSCmdlet.ShouldProcess("GitHub user [$Owner]", "Update GitHub repository [$Repository]")) {
        Invoke-GitHubRequest -Method 'PATCH' -Target "repos/$Owner/$Repository" -Body $body -Verbose:$isVerbose
    }
}