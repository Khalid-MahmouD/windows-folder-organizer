# Windows Folder Organizer - Agent Guidelines

Welcome to the `windows-folder-organizer` repository. This file provides strict guidelines for AI agents and contributors working on this project. The project primarily consists of PowerShell scripts with Windows Forms GUI, often wrapped in or embedded within Batch files for ease of execution.

## 1. Build, Lint, and Test Commands

Because this is a scripting project, there is no traditional "build" step. However, syntax validation, linting, and testing are critical.

### Linting
We use `PSScriptAnalyzer` to lint PowerShell code.
- **Run linter on all files:**
  ```powershell
  Invoke-ScriptAnalyzer -Path . -Recurse
  ```
- **Run linter on a specific file:**
  ```powershell
  Invoke-ScriptAnalyzer -Path .\FolderOrganizer.ps1
  ```

### Testing
We use `Pester` (the standard PowerShell testing framework) for unit and integration testing.
- **Run all tests:**
  ```powershell
  Invoke-Pester
  ```
- **Run a single test file:**
  ```powershell
  Invoke-Pester -Path .\tests\FolderOrganizer.tests.ps1
  ```
- **Run a single specific test (by name):**
  ```powershell
  Invoke-Pester -TestName "Should correctly map extensions to folders"
  ```
*(Note: If the `tests` directory is missing, agents should proactively create it when writing new features, following Pester conventions).*

### Execution (Manual Testing)
To manually test the scripts:
- **V1:** Double-click `FolderOrganizer.bat` or run `.\FolderOrganizer.bat` in the terminal.
- **V2 (Polyglot):** Double-click `FolderOrganizerV2.bat` or run `.\FolderOrganizerV2.bat` in the terminal.

## 2. Code Style and Conventions

### File Structure & Wrappers
- **Batch Wrappers:** Use Batch files to launch PowerShell scripts silently and bypass execution policies (e.g., `powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%SCRIPT%"`).
- **Polyglot Scripts:** If combining Batch and PowerShell (as seen in V2), use the standard `##PSSTART##` delimiter to separate Batch logic from the PowerShell payload. Extract and execute via a temporary file.

### PowerShell Code Style
- **Indentation:** Use 4 spaces for indentation. Do not use tabs.
- **Variables:** Use `camelCase` for variable names (e.g., `$folderMap`, `$targetPath`, `$previewMode`).
- **Cmdlets & Parameters:** Use `PascalCase` for cmdlets and their parameters (e.g., `Get-ChildItem -Path $targetPath -Recurse`). Avoid aliases like `ls`, `dir`, or `gci` in scripts for better readability.
- **Type Casting & .NET Classes:**
  - Import necessary .NET assemblies explicitly at the top of the file:
    ```powershell
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    ```
  - Use `PascalCase` for .NET properties and methods (e.g., `$form.StartPosition`, `$dialog.ShowDialog()`).
- **Strings:** Use double quotes (`"`) when string interpolation is required. Use single quotes (`'`) for literal strings.

### GUI Guidelines (System.Windows.Forms)
- Group GUI element creation logically (e.g., create a label, set its properties, then add it to the form controls: `$form.Controls.Add($label)`).
- Ensure the UI remains responsive. For long-running tasks, update the UI (e.g., `$form.Refresh()`, update `$log`, or `$status.Text`) to provide feedback.
- Clean up resources appropriately, especially when dealing with graphics or file locks.

### GUI Layout & Styling Pitfalls
- **Avoid Overlapping Bounds:** Do not mix fixed `Anchor` bounds and `Dock` layouts in ways that cause panels to overlap (e.g., a `Top,Left,Right,Bottom` anchored panel overlapping a `Dock=Bottom` panel). Use `Dock = "Fill"` for central content panels to cleanly consume remaining space between `Top` and `Bottom` docked header/footer panels. Note that `BringToFront()` ensures a filled panel is evaluated last so it fits perfectly between docked components without overlap.
- **Scrollbar Styling Constraints:** Native WinForms scrollbars (like those in `RichTextBox`) cannot be natively styled to match a custom dark theme. They will awkwardly render as standard Windows light gray. To maintain a cohesive dark UI, hide the native scrollbar (`$control.ScrollBars = "None"`) and rely on programmatic scrolling (e.g., `$control.ScrollToCaret()`) if manual scrolling isn't critical for the user.
- **Responsive Layout:** When setting `$form.FormBorderStyle = "Sizable"`, always ensure child controls have the correct `Anchor` properties (e.g., `"Top, Left, Right"` for horizontal stretching) so the UI doesn't break or clip when resized.

### Error Handling & Safety
- **Non-Destructive Defaults:** Tools should default to safe operations. For file operations, include preview modes or ensure directories exist before moving (e.g., `if (-not (Test-Path $destDir)) { New-Item ... }`).
- **File Name Collisions:** Always check if a file already exists at the destination. Append counters or timestamps to avoid overwriting (e.g., appending `_1`, `_2` to the base name).
- **Graceful Failures:** Catch exceptions or handle empty inputs gracefully. Show descriptive `MessageBox` prompts rather than raw console errors.
  ```powershell
  if (-not $targetPath -or -not (Test-Path $targetPath)) {
      [System.Windows.Forms.MessageBox]::Show("Please enter a valid folder path.", "Invalid Folder", "OK", "Warning")
      return
  }
  ```

### Data Structures
- **Mapping:** Use Hashtables (`@{}`) for mapping extensions to folders. Group similar extensions into arrays as values.
  ```powershell
  $folderMap = @{
      "Documents\Word" = @(".doc",".docx")
      "Images"         = @(".jpg",".jpeg",".png")
  }
  ```

### Batch to PowerShell Interop Pitfalls
- **Hiding the Console:** When launching a WinForms GUI directly from a Batch script wrapping PowerShell, *always* append `-WindowStyle Hidden` to the final `powershell` execution command. Otherwise, a black `cmd.exe` console window will persistently float behind the user's GUI.
- **Sanitizing Paths (`%~dp0`):** When passing the batch directory (`%~dp0`) as an argument into a PowerShell script block (`param([string]$AppDir)`), the trailing backslash escapes the closing quote in Windows CMD. This results in the argument absorbing the quote (e.g., `C:\Path\"`). You *must* sanitize it immediately inside the PowerShell block: `$AppDir = $AppDir.TrimEnd('"').TrimEnd('\')` to avoid `Illegal characters in path` errors.

## 3. Tool and Agent Guidelines
- **Git Safety & Commits:** Before making structural changes or using destructive bash commands (like `sed` or `rm`), you MUST verify the files are tracked in git and commit the current working state. Never attempt complex manual file restorations; rely on `git checkout` to revert mistakes.
- **Refactoring Polyglot Scripts:** When modifying `FolderOrganizerV2.bat`, preserve its "Self-Contained Polyglot" nature (a single file). However, aggressively extract logic out of WinForms event handlers (like `.Add_Click`) into dedicated PowerShell functions at the top of the script. This keeps the monolithic file organized and prevents UI code from becoming tangled with core logic.
- **Modifying GUI:** When an agent is asked to modify the UI layout, update `System.Drawing.Point` and `System.Drawing.Size` coordinates proportionally. Check for overlapping elements to prevent clipping.
- **Path Handling:** Always use `Join-Path` instead of string concatenation when building file paths to ensure cross-platform/environmental compatibility.
- **Polyglot Caution:** When editing `FolderOrganizerV2.bat`, be extremely careful not to break the Batch parsing logic at the top or the `##PSSTART##` marker.

## 4. Existing Rules Reference
- **Cursor/Copilot Rules:** No existing `.cursorrules` or `.github/copilot-instructions.md` were found in this repository. Agents should rely purely on this `AGENTS.md` document for instructions.

## 5. Custom Agent Commands
- **`/generate-test` or `/gen`**: When the user types this command, immediately execute the `tests/Generate-TestEnvironment.ps1` script to populate a test folder on their Desktop with all possible file categories, then report back when finished.

---
*This file is maintained to assist AI coding agents in making contextually accurate and stylistically consistent contributions.*