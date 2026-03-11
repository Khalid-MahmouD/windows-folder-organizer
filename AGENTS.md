# Windows Folder Organizer - Agent Guidelines

Welcome to the `windows-folder-organizer` repository. This file provides strict guidelines for AI agents and contributors working on this project. The project primarily consists of a PowerShell script with a Windows Forms GUI, which is compiled into a standalone executable.

## 1. Build, Lint, and Test Commands

Because this is a PowerShell scripting project compiled to `.exe`, traditional syntax validation, linting, and testing are critical before building.

### Building
We use `ps2exe` to compile the PowerShell script into a standalone `.exe`.
- **Run the build script:**
  ```powershell
  .\build.ps1
  ```
  *(This compiles `src/FolderOrganizer.ps1` to `bin/FolderOrganizer.exe`)*

### Linting
We use `PSScriptAnalyzer` to lint PowerShell code.
- **Run linter on all files:**
  ```powershell
  Invoke-ScriptAnalyzer -Path .\src -Recurse
  ```
- **Run linter on a specific file:**
  ```powershell
  Invoke-ScriptAnalyzer -Path .\src\FolderOrganizer.ps1
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
*(Note: If the `tests` directory is missing, agents should proactively create it when writing new features, following Pester conventions).*

### Execution (Manual Testing)
To manually test the scripts without compiling:
- Run `.\src\FolderOrganizer.ps1` in the terminal.
Or test the final build:
- Run `.\bin\FolderOrganizer.exe`

## 2. Code Style and Conventions

### File Structure
- `src/`: Contains the core PowerShell scripts (e.g., `FolderOrganizer.ps1`).
- `assets/`: Contains icons and images used for compilation.
- `bin/`: The output directory for the compiled `.exe`.

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

## 3. Tool and Agent Guidelines
- **Git Safety & Commits:** Before making structural changes or using destructive bash commands (like `sed` or `rm`), you MUST verify the files are tracked in git and commit the current working state. Never attempt complex manual file restorations; rely on `git checkout` to revert mistakes.
- **Modifying GUI:** When an agent is asked to modify the UI layout, update `System.Drawing.Point` and `System.Drawing.Size` coordinates proportionally. Check for overlapping elements to prevent clipping.
- **Path Handling:** Always use `Join-Path` instead of string concatenation when building file paths to ensure cross-platform/environmental compatibility.

## 4. Existing Rules Reference
- **Cursor/Copilot Rules:** No existing `.cursorrules` or `.github/copilot-instructions.md` were found in this repository. Agents should rely purely on this `AGENTS.md` document for instructions.

## 5. Custom Agent Commands
- **`/generate-test` or `/gen`**: When the user types this command, immediately execute the `tests/Generate-TestEnvironment.ps1` script to populate a test folder on their Desktop with all possible file categories, then report back when finished.

---
*This file is maintained to assist AI coding agents in making contextually accurate and stylistically consistent contributions.*
