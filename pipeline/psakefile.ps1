TaskSetup {
    Set-Location $ProjectRoot
}

Task BuildModule -RequiredVariables ProjectRoot,
    ModuleName,
    BaseVersionNumber {
    & $ProjectRoot\pipeline\scripts\Build-Module `
        -ModuleName $ModuleName `
        -BaseVersionNumber $BaseVersionNumber `
        -PrereleaseTag $PrereleaseTag
}
