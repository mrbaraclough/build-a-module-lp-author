foreach ($file in Get-ChildItem "$($PSScriptRoot)\Private", "$($PSScriptRoot)\\Public") {
    . $file.FullName
}
