JassPlus.VS2026 1.0.0

Installation
1. Close all Visual Studio windows on the target computer.
2. Copy JassPlus.VS2026-1.0.0.vsix to that computer and double-click it.
3. In Visual Studio Installer, select the Visual Studio 2022/2026 instance and install.
4. Reopen Visual Studio. The extension is available for .j, .ai, .dz, .wts, and .jassproj files.

Requirements
- 64-bit Windows
- Visual Studio 2022 17.8 or later, or Visual Studio 2026 (Community, Professional, or Enterprise)
- Visual Studio Core Editor component
- .NET Framework 4.7.2 or later

Trust notice
This is an unsigned VSIX distributed directly for interim use. Visual Studio may show a publisher trust prompt during installation. Verify the SHA-256 checksum in SHA256SUMS.txt before installing if the file was transferred through another computer or storage service.

Included capabilities
- JASS/vJASS syntax highlighting, completion, Quick Info, signature help, navigation, references, outline, formatting, and diagnostics
- Bundled common.j and Blizzard.j API data
- Warcraft III map script working-copy workflow for war3map.j and war3map.wts

Known scope
- .w3i and other binary map sections do not have structured editors.
- Map modifications are saved to a separate map file; verify the output in World Editor or Warcraft III before using it as a production map.
- Diagnostics are conservative and may not cover every JASS compiler/JassHelper dialect rule.
- This is a sideload package; it is not published to Visual Studio Marketplace and will not auto-update.

