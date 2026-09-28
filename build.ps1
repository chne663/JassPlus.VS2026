#Requires -Version 5.1
<#
.SYNOPSIS
    Restores, builds, and tests JassPlus.VS2026.

.DESCRIPTION
    Convenience wrapper. Run from a Visual Studio Developer PowerShell
    (or plain PowerShell with the .NET 8 SDK and Visual Studio 2026's or
    2022's MSBuild on PATH) so the VSIX project's build tooling is available.

.PARAMETER Configuration
    Debug (default) or Release.

.PARAMETER SkipTests
    Skip running the JassPlus.Language.Tests project.
#>
param(
    [ValidateSet("Debug", "Release")]
    [string]$Configuration = "Debug",

    [switch]$SkipTests
)

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$sln = Join-Path $root "JassPlus.VS2026.sln"

Write-Host "==> dotnet restore" -ForegroundColor Cyan
dotnet restore $sln
if ($LASTEXITCODE -ne 0) { throw "restore failed" }

Write-Host "==> dotnet build ($Configuration)" -ForegroundColor Cyan
dotnet build $sln -c $Configuration --no-restore
if ($LASTEXITCODE -ne 0) { throw "build failed" }

if (-not $SkipTests) {
    Write-Host "==> dotnet test" -ForegroundColor Cyan
    dotnet test (Join-Path $root "tests\JassPlus.Language.Tests\JassPlus.Language.Tests.csproj") -c $Configuration --no-build
    if ($LASTEXITCODE -ne 0) { throw "tests failed" }
}

$vsix = Get-ChildItem -Path (Join-Path $root "src\JassPlus.VSIX\bin\$Configuration") -Filter "*.vsix" -Recurse -ErrorAction SilentlyContinue |
    Select-Object -First 1

if ($vsix) {
    Write-Host "==> VSIX produced: $($vsix.FullName)" -ForegroundColor Green
} else {
    Write-Host "==> No .vsix found under src\JassPlus.VSIX\bin\$Configuration — check build output above." -ForegroundColor Yellow
}
