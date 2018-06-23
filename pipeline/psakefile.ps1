TaskSetup {
    Set-Location $ProjectRoot
}

Task Build -RequiredVariables ProjectRoot,
    ModuleName,
    BaseVersionNumber {
    & (Join-Path $ProjectRoot "pipeline\scripts\Build-Module") `
        -ProjectRoot $ProjectRoot `
        -ModuleName $ModuleName `
        -BaseVersionNumber $BaseVersionNumber `
        -PrereleaseTag $PrereleaseTag
}

Task Test -RequiredVariables ProjectRoot,
    ModuleName {
    & (Join-Path $ProjectRoot "pipeline\scripts\Test-Module") `
        -ProjectRoot $ProjectRoot `
        -ModuleName $ModuleName
}

Task UploadTestResults -RequiredVariables ProjectRoot,
    ModuleName,
    TestResultsEndpoint {
    & (Join-Path $ProjectRoot "pipeline\scripts\Upload-TestResults") `
        -ProjectRoot $ProjectRoot `
        -ModuleName $ModuleName `
        -TestResultsEndpoint $TestResultsEndpoint
}

Task Publish -RequiredVariables ProjectRoot,
    ModuleName,
    NugetApiKey {
    & (Join-Path $ProjectRoot "pipeline\scripts\Publish-Module") `
        -ProjectRoot $ProjectRoot `
        -ModuleName $ModuleName `
        -NugetApiKey $NugetApiKey
}
