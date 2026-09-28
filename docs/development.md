# Development Guide

## Prerequisites

- Windows 10/11
- Visual Studio 2026 (any edition) or Visual Studio 2022 17.8+, with the
  **Visual Studio extension development**
  workload installed (Installer → Modify → Workloads →
  "Visual Studio extension development")
- .NET Framework 4.7.2 Developer Pack (installed automatically by the
  workload above, but double-check under Individual Components if a restore
  error mentions it)
- .NET 8 SDK (for building/running `JassPlus.Language.Tests`)

## Getting the code building

1. Clone the repository.
2. Open `JassPlus.VS2026.sln` in Visual Studio 2026 (or Visual Studio 2022).
3. Let NuGet restore run (this pulls `Microsoft.VisualStudio.SDK` and
   `Microsoft.VSSDK.BuildTools` for the VSIX project, and the xUnit packages
   for the test project).
4. **Build → Build Solution** (or `Ctrl+Shift+B`).

Command line, from the repo root:

```powershell
dotnet restore
dotnet build JassPlus.VS2026.sln -c Debug
```

> Note: `JassPlus.VSIX.csproj` targets `net472` and depends on
> `Microsoft.VisualStudio.SDK`, which only resolves correctly inside a
> Visual Studio / MSBuild-with-VSSDK-BuildTools environment. Plain
> `dotnet build` on a machine without Visual Studio installed may fail to
> restore this project — that's expected; use `msbuild` from a Developer
> Command Prompt, or build from within Visual Studio, for `JassPlus.VSIX`.
> `JassPlus.Language` and `JassPlus.Language.Tests` build fine with a bare
> .NET 8 SDK on any OS since they don't touch the VS SDK.

The build produces:

```
src/JassPlus.VSIX/bin/Debug/net472/JassPlus.VSIX.vsix
```

## Running the unit tests

```powershell
dotnet test tests/JassPlus.Language.Tests/JassPlus.Language.Tests.csproj
```

or via Visual Studio's Test Explorer (Test → Test Explorer → Run All).

## Debugging the extension (Experimental Instance)

1. Set `JassPlus.VSIX` as the startup project (right-click → *Set as
   Startup Project*).
2. Press `F5` (Debug → Start Debugging).
3. Visual Studio launches a second, isolated instance of itself — the
   **Experimental Instance** — using the `/rootsuffix Exp` hive so your
   real VS settings/extensions are untouched. This is preconfigured in
   `JassPlus.VSIX.csproj` via `StartArguments = /rootsuffix Exp`.
4. In the Experimental Instance: **File → Open → File...** and open or
   create a `.j` file to see the extension in action.
5. Set breakpoints in `JassPlus.VSIX` source back in the main VS instance —
   they'll bind and hit as the Experimental Instance runs.

### Phase 4 map script extraction

In the Experimental Instance, choose **Tools → Open Warcraft III Map
Script...** and select a `.w3x` or `.w3m` map. The command extracts
`war3map.j` and optional `war3map.wts` into `%LOCALAPPDATA%\JassPlus\MapWorkspaces`
and opens both copies. The map path is included in the confirmation message.
Reopening the same map reuses that working copy so edits are not discarded.
This keeps the source map untouched. To package edits, choose **Tools → Save JASS
Working Copy to Map As...** and save to a new `.w3x` / `.w3m` file. The
extension rebuilds the MPQ, retains other map entries, and verifies the
packaged `war3map.j` and `war3map.wts` before it completes. It blocks the save
if a JASS string literal references a missing `TRIGSTR_###` entry or the WTS
defines the same string ID more than once. Embedded signatures are removed
because changing the archive invalidates them. When JassHelper is configured
under **Tools → Options → Warcraft III → JASS**, the command compiles first
and packages the compiler output; a failed compile stops the save. With no
JassHelper path configured, the active script is packaged as-is. To smoke-test,
save to a new filename, open that output map with the same command, and check
that the edited script is present; then validate the map in Warcraft III or
the map editor. The original map is never overwritten by this command.

If the Experimental Instance ever gets into a broken state (stale MEF
cache, etc.), reset it from a Developer Command Prompt:

```powershell
devenv /rootsuffix Exp /resetsettings
devenv /rootsuffix Exp /updateconfiguration
```

## Manually installing the built VSIX

Instead of `F5` debugging, you can install the extension into your regular
Visual Studio like any other extension:

1. Build the solution (Release configuration recommended for a "real"
   install).
2. Double-click `src/JassPlus.VSIX/bin/Release/net472/JassPlus.VSIX.vsix`.
3. Follow the VSIX Installer prompts.
4. Restart Visual Studio.
5. Uninstall later via **Extensions → Manage Extensions** → find
   "Warcraft III JASS Tools" → Uninstall.

## Verifying Phase 1 manually

See the checklist in the root [README.md](../README.md#installation--phase-1-verification-checklist).
