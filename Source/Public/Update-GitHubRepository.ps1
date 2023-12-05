function Update-GitHubRepository {
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
        $Repository,

        [string]$Name,

        [string]$Description,

        [string]$Homepage,

        [bool]$Private = $false,

        [ValidateSet("public", "private")]
        [string]$Visibility,

        [object]$SecurityAndAnalysis = $null,

        [bool]$SecurityAndAnalysisHasIssues = $true,
        [bool]$SecurityAndAnalysisHasProjects = $true,
        [bool]$SecurityAndAnalysisHasWiki = $true,
        [bool]$SecurityAndAnalysisIsTemplate = $false,
        [string]$SecurityAndAnalysisDefaultBranch,

        [bool]$SecurityAndAnalysisAllowSquashMerge = $true,
        [bool]$SecurityAndAnalysisAllowMergeCommit = $true,
        [bool]$SecurityAndAnalysisAllowRebaseMerge = $true,
        [bool]$SecurityAndAnalysisAllowAutoMerge = $false,
        [bool]$SecurityAndAnalysisDeleteBranchOnMerge = $false,
        [bool]$SecurityAndAnalysisAllowUpdateBranch = $false,
        [bool]$SecurityAndAnalysisUseSquashPrTitleAsDefault = $false,

        [ValidateSet("PR_TITLE", "COMMIT_OR_PR_TITLE")]
        [string]$SecurityAndAnalysisSquashMergeCommitTitle = "PR_TITLE",

        [ValidateSet("PR_BODY", "COMMIT_MESSAGES", "BLANK")]
        [string]$SecurityAndAnalysisSquashMergeCommitMessage = "PR_BODY",

        [ValidateSet("PR_TITLE", "MERGE_MESSAGE")]
        [string]$SecurityAndAnalysisMergeCommitTitle = "PR_TITLE",

        [ValidateSet("PR_TITLE", "PR_BODY", "BLANK")]
        [string]$SecurityAndAnalysisMergeCommitMessage = "PR_TITLE",

        [bool]$SecurityAndAnalysisArchived = $false,
        [bool]$SecurityAndAnalysisAllowForking = $false,
        [bool]$SecurityAndAnalysisWebCommitSignoffRequired = $false
    )

    # Populate Body
    $body = @{}

    # Invoke
    Invoke-GitHubRequest -Owner $Owner -Repository $Repository -Method 'PATCH' -Body $body

}