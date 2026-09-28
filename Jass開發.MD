# Visual Studio 2022 Warcraft III JASS / vJASS 擴充套件開發需求

## 一、專案背景

目前 Warcraft III 地圖開發者常使用 JASS / vJASS 進行地圖腳本開發。

目前 Visual Studio Code 上曾經有一個相當實用的 JASS+ 擴充套件，由作者 **unouo** 維護：

* 作者：unouo
* Marketplace：Jass+
* 主要用途：Warcraft III JASS / vJASS 程式碼編輯、語法高亮、程式碼輔助等

但目前該作者已長期沒有持續維護，因此希望重新製作一個**現代化、可長期維護的 Visual Studio 2022 擴充套件**。

目標不是單純將 VS Code Extension 搬到 Visual Studio，而是使用 Visual Studio 2022 原生 Extension 架構重新實作。

---

# 二、專案目標

請協助建立一個完整的：

**Warcraft III JASS / vJASS Visual Studio 2022 Extension**

暫定名稱：

**JassPlus.VS2022**

或：

**Warcraft III JASS Tools**

最終名稱可以再討論。

主要目標：

1. 支援 Visual Studio 2022
2. 支援 JASS
3. 支援 vJASS
4. 提供完整語法高亮
5. 提供程式碼自動完成
6. 提供基本語法錯誤檢查
7. 提供函式、變數、常數、型別等符號資訊
8. 支援 Go to Definition
9. 支援 Find All References
10. 支援 Outline / Document Symbols
11. 支援程式碼格式化
12. 支援 JASS / vJASS 專案管理
13. 支援 Warcraft III 原生 API
14. 支援自訂 `.j`、`.ai`、`.dz` 等相關腳本檔案
15. 未來可擴充對 Warcraft III 地圖 / `.w3x` 開發流程的支援

---

# 三、重要要求

## 不要直接移植 VS Code Extension

不要直接將原本 Jass+ 的 TypeScript / VS Code API 架構硬搬到 Visual Studio。

Visual Studio 2022 應使用 Microsoft 官方 Extension SDK，例如：

* Visual Studio SDK
* VSIX
* Managed Package Framework / AsyncPackage
* MEF
* Microsoft.VisualStudio.LanguageServices
* Visual Studio Editor APIs
* Classification / Tagging
* Completion
* QuickInfo
* Navigation
* Diagnostics
* Workspace / Project System

請依照 Visual Studio 2022 官方推薦架構設計。

---

# 四、建議技術架構

請優先考慮以下架構：

```text
JassPlus.VS2022
│
├── JassPlus.VSIX
│   └── Visual Studio Extension Package
│
├── JassPlus.Language
│   ├── Lexer
│   ├── Parser
│   ├── AST
│   ├── SymbolTable
│   ├── TypeSystem
│   ├── Diagnostics
│   └── Formatter
│
├── JassPlus.Editor
│   ├── Syntax Highlighting
│   ├── Completion
│   ├── QuickInfo
│   ├── GoToDefinition
│   ├── FindReferences
│   └── DocumentOutline
│
├── JassPlus.Project
│   ├── JASS Project
│   ├── vJASS Project
│   ├── Include Management
│   └── Library Management
│
├── JassPlus.Warcraft
│   ├── Native Functions
│   ├── Common.j
│   ├── Blizzard.j
│   └── Warcraft III API
│
└── Tests
    ├── LexerTests
    ├── ParserTests
    ├── CompletionTests
    └── DiagnosticsTests
```

語言核心與 Visual Studio UI / Extension 層請盡可能分離。

這樣未來即使要支援 Visual Studio Code、Rider 或其他 IDE，也可以重用 JASS Language Server / Parser。

---

# 五、JASS 語言支援

首先完整支援 Warcraft III JASS 基本語法。

例如：

```jass
function Test takes nothing returns nothing
    local integer i = 0

    set i = i + 1

    call BJDebugMsg("Hello Warcraft III")

    return
endfunction
```

需要正確辨識：

### 關鍵字

例如：

```text
globals
endglobals

function
endfunction

takes
returns

nothing

local
set
call
return

if
then
elseif
else
endif

loop
endloop

exitwhen

constant
native

type
extends

array
```

實際關鍵字請依 Warcraft III JASS 語法完整整理，不要只列出上述範例。

---

# 六、vJASS 支援

這是本專案非常重要的部分。

需要支援常見 vJASS 語法，例如：

```jass
library Test requires ABC

struct MyStruct

    integer value

    method setValue takes integer v returns nothing
        set .value = v
    endmethod

endstruct

endlibrary
```

以及：

```jass
scope Test initializer Init

private function Init takes nothing returns nothing
endfunction

endscope
```

需要考慮：

```text
library
endlibrary

scope
endscope

struct
endstruct

method
endmethod

interface
endinterface

module
endmodule

implement
implement

private
public
static

library_once

requires
uses

initializer

optional

defaults

thistype

super

this

delegate

method
```

以及其他主流 JassHelper / vJASS 語法。

請不要只支援少數範例，應建立可擴充的 Lexer / Parser。

---

# 七、語法高亮

Visual Studio 編輯器需要提供完整 JASS / vJASS Syntax Highlighting。

至少區分：

```text
Keyword
Type
Native
Function
Method
Variable
Constant
Local Variable
Global Variable
Struct
Library
Scope
Interface
String
Number
Comment
Operator
Preprocessor
FourCC
Handle Type
BJ Function
JASS Native
vJASS Keyword
```

例如：

```jass
function CreateUnitEx takes player whichPlayer, integer unitid returns unit
    local unit u

    set u = CreateUnit(whichPlayer, unitid, 0.0, 0.0, 0.0)

    return u
endfunction
```

應能區分：

* `function`
* `takes`
* `returns`
* `local`
* `unit`
* `player`
* `integer`
* `CreateUnit`
* `set`
* `return`
* 變數 `u`

---

# 八、自動完成 IntelliSense

需要提供基本 IntelliSense。

例如輸入：

```jass
call Create
```

可以出現：

```text
CreateUnit
CreateUnitAtLoc
CreateGroup
CreateForce
CreateTimer
CreateTrigger
...
```

選擇函式後可以顯示：

```text
CreateUnit(
    player whichPlayer,
    integer unitid,
    real x,
    real y,
    real face
) returns unit
```

---

# 九 Warcraft III Native API

請建立 Warcraft III Native Database。

至少包含：

```text
common.j
blizzard.j
```

中的 Native / Function / Type / Constant 定義。

例如：

```jass
native CreateUnit takes player id, integer unitid, real x, real y, real face returns unit
```

IntelliSense 應能解析：

```text
CreateUnit
```

並顯示：

```text
CreateUnit(player id, integer unitid, real x, real y, real face) returns unit
```

同時支援：

```text
integer
real
boolean
string
handle
player
unit
item
ability
timer
trigger
group
force
location
effect
sound
quest
dialog
button
region
rect
camera
fogmodifier
...
```

不要將 API 硬編碼在 UI 中。

建議建立獨立：

```text
WarcraftApi.json
```

或：

```text
common.j
blizzard.j
```

解析器。

---

# 十、Go To Definition

例如：

```jass
call MyFunction()
```

按：

```text
F12
```

應跳到：

```jass
function MyFunction takes nothing returns nothing
```

也需要支援：

* Function
* Native
* Global Variable
* Local Variable
* Struct
* Method
* Library
* Scope
* Type

---

# 十一、Find All References

例如：

```jass
MyFunction()
```

可以搜尋整個專案：

```text
MyFunction
```

並列出：

```text
Test.j
    line 10

Ability.j
    line 50

Library.j
    line 123
```

---

# 十二、Diagnostics

需要基本語法分析。

例如：

```jass
function Test takes nothing returns nothing
    set x = 123
endfunction
```

如果 `x` 沒有宣告：

```text
The variable 'x' could not be resolved.
```

例如：

```jass
function Test takes integer x returns nothing

endfunction
```

應檢查：

* 括號
* function/endfunction
* if/endif
* loop/endloop
* library/endlibrary
* scope/endscope
* struct/endstruct
* method/endmethod
* 型別
* 未宣告變數
* 函式參數
* include
* requires

錯誤應顯示在 Visual Studio Error List。

---

# 十三、Formatter

提供：

```text
Format Document
```

以及：

```text
Format Selection
```

例如：

原始：

```jass
function Test takes nothing returns nothing
local integer i
if i==1 then
call BJDebugMsg("test")
endif
endfunction
```

格式化後：

```jass
function Test takes nothing returns nothing
    local integer i

    if i == 1 then
        call BJDebugMsg("test")
    endif
endfunction
```

格式化規則需要可設定。

---

# 十四、Project 支援

希望可以建立：

```text
Warcraft III JASS Project
```

例如：

```text
MyMap
│
├── Scripts
│   ├── common.j
│   ├── blizzard.j
│   ├── Main.j
│   ├── Hero.j
│   └── Ability.j
│
├── Libraries
│   ├── TimerUtils.j
│   └── Table.j
│
└── MyMap.jassproj
```

可以設計自己的：

```xml
<JassProject>
    <Name>MyMap</Name>

    <Files>
        <File Include="Scripts\Main.j" />
        <File Include="Scripts\Hero.j" />
    </Files>

    <Libraries>
        <Library Include="Libraries\TimerUtils.j" />
    </Libraries>
</JassProject>
```

不要求第一版就完成完整 MSBuild 整合，但架構必須保留未來擴充空間。

---

# 十五、Include / Requires

需要解析：

```jass
//! import "MyLibrary.j"
```

以及 vJASS：

```jass
library Hero requires TimerUtils, Table
```

自動建立 Dependency Graph：

```text
Main
 ├── Hero
 │    ├── TimerUtils
 │    └── Table
 │
 └── UI
```

這可以讓 IntelliSense 和 Go To Definition 正確跨檔案運作。

---

# 十六、Warcraft III 版本相容性

請考慮 Warcraft III 不同版本。

至少不要把 Parser 寫死成單一版本。

架構上應支援：

```text
Warcraft III Classic
Warcraft III Reforged
JASS
vJASS
JassHelper
```

未來可以增加：

```text
Lua
Wurst
Zinc
```

但第一階段只做：

**JASS + vJASS**

---

# 十七、JassHelper 相容性

vJASS 最終通常會經過 JassHelper 編譯。

因此可以考慮提供：

Visual Studio：

```text
Build
```

執行：

```text
JassHelper.exe
```

例如：

```text
Tools
 └── Warcraft III
      ├── JassHelper.exe
      └── common.j
```

使用者可以在：

```text
Tools → Options → Warcraft III → JASS
```

設定：

```text
JassHelper Path
Warcraft III Path
Common.j Path
Blizzard.j Path
```

如果 JassHelper 不存在，Extension 仍然可以單獨提供編輯 / IntelliSense 功能。

---

# 十八、設定頁面

Visual Studio：

```text
Tools
 → Options
   → Warcraft III
      → JASS
```

提供：

```text
Warcraft III Installation Path

JassHelper Path

Common.j Path

Blizzard.j Path

Default Script Encoding

Indent Size

Use Spaces

Enable Diagnostics

Enable IntelliSense

Enable Auto Formatting
```

---

# 十九、編碼支援

Warcraft III 舊地圖可能存在：

```text
ANSI
Windows-1252
UTF-8
UTF-8 BOM
Big5
```

請不要假設所有 `.j` 都是 UTF-8。

需要考慮舊 Warcraft III 地圖與台灣環境常見的 Big5 / ANSI 腳本。

---

# 二十、第一階段 MVP

不要一次把所有功能做完。

請先建立一個「可以真正安裝使用」的 VSIX。

MVP 必須包含：

### 1.

Visual Studio 2022 Extension

```text
.vsix
```

可以正常安裝。

### 2.

`.j` 檔案關聯。

### 3.

JASS Syntax Highlighting。

### 4.

vJASS Syntax Highlighting。

### 5.

基本 Lexer / Parser。

### 6.

Warcraft III Native API。

### 7.

IntelliSense。

### 8.

Go To Definition。

### 9.

Error List 基本 Diagnostics。

完成以上功能後，再逐步增加：

```text
Find References
Formatter
Project System
JassHelper Build
Dependency Graph
Warcraft III Map Integration
```

---

# 二十一、開發環境

請以：

```text
Windows 10 / Windows 11
Visual Studio 2022
.NET
C#
Visual Studio SDK
VSIX
```

作為主要開發環境。

請確認可以使用目前 Visual Studio 2022 支援的 SDK / Target Framework。

不要依賴已停止維護的舊 Visual Studio SDK。

---

# 二十二、Repository 結構

建議：

```text
JassPlus.VS2022/
│
├── README.md
├── LICENSE
├── CHANGELOG.md
├── .gitignore
│
├── src/
│   ├── JassPlus.VSIX/
│   ├── JassPlus.Language/
│   ├── JassPlus.Editor/
│   ├── JassPlus.Project/
│   └── JassPlus.Warcraft/
│
├── tests/
│   ├── JassPlus.Language.Tests/
│   └── JassPlus.Editor.Tests/
│
├── resources/
│   ├── common.j
│   ├── blizzard.j
│   └── WarcraftApi.json
│
└── docs/
    ├── architecture.md
    ├── development.md
    └── jass-language.md
```

---

# 二十三、測試要求

請建立 Unit Tests。

至少測試：

### Lexer

```text
Keywords
Identifiers
Strings
Numbers
Comments
Operators
FourCC
```

### Parser

```text
Function
Native
Global
Local
If
Loop
Struct
Method
Library
Scope
Requires
```

### IntelliSense

測試：

```text
CreateUnit
BJDebugMsg
自訂 Function
Struct Method
Global Variable
```

### Diagnostics

測試：

```text
Undefined variable
Undefined function
Missing endfunction
Missing endif
Invalid type
```

---

# 二十四、必須提供完整原始碼

請不要只提供概念或架構。

我需要：

1. 完整 Visual Studio Solution
2. 完整 `.csproj`
3. 完整 VSIX 專案
4. 完整 C# Source Code
5. Parser
6. Lexer
7. Syntax Highlighting
8. IntelliSense
9. Diagnostics
10. Warcraft API Database
11. Unit Tests
12. README
13. Build Script

最後可以直接執行：

```powershell
dotnet build
```

或 Visual Studio：

```text
Build → Build Solution
```

產生：

```text
JassPlus.VS2022.vsix
```

---

# 二十五、安裝測試

請提供完整測試流程：

```text
1. 安裝 Visual Studio 2022
2. 安裝必要 Workload
3. 開啟 Solution
4. Build
5. 產生 VSIX
6. 安裝 VSIX
7. 開啟 Visual Studio
8. 建立 / 開啟 .j
9. 測試 Syntax Highlighting
10. 測試 IntelliSense
11. 測試 F12
12. 測試 Error List
```

並說明如何 Debug Extension：

```text
Debug → Start
```

以及 Experimental Instance 的使用方式。

---

# 二十六、GitHub 專案

請以適合公開 GitHub Repository 的方式設計。

Repository：

```text
JassPlus.VS2022
```

需要包含：

```text
README.md
LICENSE
CONTRIBUTING.md
CHANGELOG.md
```

README 至少說明：

```text
Features
Requirements
Installation
Development
Build
Debug
Configuration
JASS Support
vJASS Support
JassHelper Integration
Known Issues
Roadmap
License
```

---

# 二十七、授權與原專案

原始 Jass+ 專案與其程式碼、資源、名稱、圖示等，請先確認其 License。

**不要直接複製原作者沒有明確授權可以重新使用的程式碼、圖片或資源。**

可以：

* 參考其功能
* 參考公開文件
* 重新設計架構
* 重新實作 Parser
* 重新實作 Visual Studio Extension
* 使用 Warcraft III 公開可取得的 API 定義

如果需要使用原 Jass+ 的任何程式碼，請先確認 License 是否允許。

本專案希望成為：

**獨立、開源、可長期維護的 Visual Studio 2022 Warcraft III JASS / vJASS 開發工具。**

---

# 二十八、開發方式

請採取「可編譯、可測試、逐步完成」的方式。

不要一次產生大量沒有辦法編譯的程式碼。

建議依照：

```text
Phase 1
Visual Studio Extension + VSIX
        ↓
Phase 2
JASS Lexer
        ↓
Phase 3
Syntax Highlighting
        ↓
Phase 4
Parser / AST
        ↓
Phase 5
Native API
        ↓
Phase 6
IntelliSense
        ↓
Phase 7
Go To Definition
        ↓
Phase 8
Diagnostics
        ↓
Phase 9
Formatter
        ↓
Phase 10
JassHelper Integration
        ↓
Phase 11
JASS Project System
```

每個 Phase 完成後都必須：

```text
可以 Build
可以測試
可以執行
```

再進入下一階段。

---

# 二十九、最重要的成果

最終希望做到的使用體驗：

使用者開啟 Visual Studio 2022：

```text
File
 → Open
   → MyMap.j
```

Visual Studio 可以像開發 C# 一樣：

```text
function Test takes nothing returns nothing

    local integer i

    set i = 0

    call BJDebugMsg("Hello")

endfunction
```

具有：

```text
語法高亮
↓
IntelliSense
↓
函式參數提示
↓
錯誤提示
↓
F12 跳轉
↓
Find References
↓
程式碼格式化
↓
JassHelper 編譯
```

最終讓 Warcraft III JASS / vJASS 開發者可以直接使用：

**Visual Studio 2022 作為主要 Warcraft III 地圖腳本 IDE。**

請先從 **Phase 1：Visual Studio 2022 VSIX 基礎專案 + JASS `.j` 檔案語言服務骨架** 開始。

第一階段完成後，請提供：

1. 完整 Solution
2. 所有必要 C# 程式碼
3. `.csproj`
4. `.vsixmanifest`
5. 安裝 / Build 指令
6. 專案目錄結構
7. 如何在 Visual Studio 2022 啟動 Extension Experimental Instance
8. 第一階段可以實際驗證的測試方式

請不要只給我程式碼片段，要以**可以直接建立 GitHub Repository 並開始編譯的完整專案**為目標。
