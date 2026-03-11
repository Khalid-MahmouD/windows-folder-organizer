@echo off
setlocal

set "TMPPS=%TEMP%\FolderOrganizerV2_%RANDOM%.ps1"

powershell -ExecutionPolicy Bypass -Command ^
  "$content = Get-Content '%~f0' -Raw; $start = $content.IndexOf('##PSSTART##') + 11; $ps = $content.Substring($start).TrimStart([char]13,[char]10); [System.IO.File]::WriteAllText('%TMPPS%', $ps, [System.Text.Encoding]::UTF8)"

powershell -ExecutionPolicy Bypass -NoProfile -File "%TMPPS%"
del "%TMPPS%" 2>nul
exit /b

##PSSTART##
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ── Folder map ────────────────────────────────────────────────
$folderMap = @{
    "Documents\PDFs"        = @(".pdf")
    "Documents\Word"        = @(".doc",".docx")
    "Documents\Excel"       = @(".xls",".xlsx",".csv")
    "Documents\PowerPoint"  = @(".ppt",".pptx")
    "Documents\Text"        = @(".txt",".rtf",".md")
    "Images"                = @(".jpg",".jpeg",".png",".gif",".bmp",".webp",".svg",".heic",".raw")
    "Videos"                = @(".mp4",".mov",".avi",".mkv",".wmv",".flv",".m4v",".webm")
    "Music"                 = @(".mp3",".wav",".flac",".aac",".ogg",".wma",".m4a")
    "Installers"            = @(".exe",".msi",".msix",".appx",".dmg",".pkg",".deb",".rpm")
    "Compressed"            = @(".zip",".rar",".7z",".tar",".gz",".bz2",".xz")
    "Code"                  = @(".py",".js",".ts",".html",".css",".json",".xml",".sql",".sh",".bat",".ps1")
    "Fonts"                 = @(".ttf",".otf",".woff",".woff2")
    "Torrents"              = @(".torrent")
}

$extMap = @{}
foreach ($folder in $folderMap.Keys) {
    foreach ($ext in $folderMap[$folder]) { $extMap[$ext] = $folder }
}

# ── Color Palette ─────────────────────────────────────────────
$clrBg        = [System.Drawing.Color]::FromArgb(10, 10, 15)
$clrSurface   = [System.Drawing.Color]::FromArgb(18, 18, 26)
$clrCard      = [System.Drawing.Color]::FromArgb(26, 26, 38)
$clrBorder    = [System.Drawing.Color]::FromArgb(45, 45, 65)
$clrAccent    = [System.Drawing.Color]::FromArgb(99, 179, 237)
$clrAccent2   = [System.Drawing.Color]::FromArgb(154, 117, 255)
$clrSuccess   = [System.Drawing.Color]::FromArgb(72, 199, 142)
$clrText      = [System.Drawing.Color]::FromArgb(230, 230, 245)
$clrMuted     = [System.Drawing.Color]::FromArgb(120, 120, 150)
$clrLogBg     = [System.Drawing.Color]::FromArgb(13, 13, 20)

# ── Fonts ──────────────────────────────────────────────────────
$fontTitle    = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
$fontSub      = New-Object System.Drawing.Font("Segoe UI", 9)
$fontLabel    = New-Object System.Drawing.Font("Segoe UI Semibold", 9, [System.Drawing.FontStyle]::Bold)
$fontInput    = New-Object System.Drawing.Font("Segoe UI", 10)
$fontBtn      = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$fontLog      = New-Object System.Drawing.Font("Cascadia Code", 8.5)
$fontLogFall  = New-Object System.Drawing.Font("Consolas", 9)
$fontSmall    = New-Object System.Drawing.Font("Segoe UI", 8)
$fontCounter  = New-Object System.Drawing.Font("Segoe UI", 22, [System.Drawing.FontStyle]::Bold)

# ── Functions ──────────────────────────────────────────────────
function MakeStatBox($parent, $x, $value, $label) {
    $pnl = New-Object System.Windows.Forms.Panel
    $pnl.Location = New-Object System.Drawing.Point($x, 0)
    $pnl.Size = New-Object System.Drawing.Size(158, 68)
    $pnl.BackColor = [System.Drawing.Color]::Transparent
    $parent.Controls.Add($pnl)

    $lv = New-Object System.Windows.Forms.Label
    $lv.Text = $value
    $lv.Font = $fontCounter
    $lv.ForeColor = $clrAccent
    $lv.Location = New-Object System.Drawing.Point(0, 6)
    $lv.Size = New-Object System.Drawing.Size(158, 34)
    $lv.TextAlign = "MiddleCenter"
    $lv.BackColor = [System.Drawing.Color]::Transparent
    $pnl.Controls.Add($lv)

    $ll = New-Object System.Windows.Forms.Label
    $ll.Text = $label
    $ll.Font = $fontSmall
    $ll.ForeColor = $clrMuted
    $ll.Location = New-Object System.Drawing.Point(0, 42)
    $ll.Size = New-Object System.Drawing.Size(158, 18)
    $ll.TextAlign = "MiddleCenter"
    $ll.BackColor = [System.Drawing.Color]::Transparent
    $pnl.Controls.Add($ll)

    # Divider (except last)
    if ($x -lt 474) {
        $div = New-Object System.Windows.Forms.Panel
        $div.Location = New-Object System.Drawing.Point(($x + 158), 14)
        $div.Size = New-Object System.Drawing.Size(1, 40)
        $div.BackColor = $clrBorder
        $parent.Controls.Add($div)
    }
    return $lv
}

function UpdateStats($path) {
    if (Test-Path $path) {
        $files = Get-ChildItem -Path $path -File
        $script:lblStatFiles.Text = $files.Count.ToString()
        $script:lblStatMoved.Text = "0"
        $script:lblStatSkip.Text  = "0"
        $cats = ($files | ForEach-Object { $ext = $_.Extension.ToLower(); if ($extMap[$ext]) { $extMap[$ext] } else { "Other" } } | Sort-Object -Unique).Count
        $script:lblStatCats.Text = $cats.ToString()
        $form.Refresh()
    }
}

function LogLine($msg, $color) {
    $rtbLog.SelectionStart = $rtbLog.TextLength
    $rtbLog.SelectionLength = 0
    $rtbLog.SelectionColor = $color
    $rtbLog.AppendText("$msg`n")
    $rtbLog.ScrollToCaret()
    $form.Refresh()
}

function Invoke-OrganizeFolder {
    $targetPath = $txtPath.Text.Trim()
    if ($targetPath -eq "Select or paste a folder path..." -or $targetPath -eq "") {
        [System.Windows.Forms.MessageBox]::Show("Please select a folder first.", "No Folder Selected", "OK", "Warning")
        return
    }
    if (-not (Test-Path $targetPath)) {
        [System.Windows.Forms.MessageBox]::Show("Folder not found:`n$targetPath", "Invalid Folder", "OK", "Error")
        return
    }

    $isPreview = $chkPreview.Checked
    $includeSubfolders = $chkSubfolders.Checked

    if (-not $isPreview) {
        $global:undoLog = @()
        $btnUndo.Enabled = $false
    }

    $rtbLog.Clear()
    $btnOrganize.Enabled = $false
    $btnOrganize.Text = "Working..."
    $lblStatus.Text = "Scanning folder..."
    $form.Refresh()

    $getArgs = @{ Path = $targetPath; File = $true }
    if ($includeSubfolders) { $getArgs["Recurse"] = $true }

    $files = Get-ChildItem @getArgs | Where-Object { $_.Name -notmatch "FolderOrganizer" }
    $total = $files.Count
    $moved = 0
    $skipped = 0
    $catsUsed = @{}
    $i = 0

    if ($total -eq 0) {
        LogLine "  No files found in this folder." ([System.Drawing.Color]::FromArgb(251, 191, 36))
        $lblStatus.Text = "No files found."
    } else {
        $pbProgress.Maximum = $total
        $modeTag = if ($isPreview) { "[PREVIEW] " } else { "" }
        LogLine "${modeTag}Organizing: $targetPath" $clrAccent
        LogLine ("─" * 60) $clrBorder
        LogLine "" $clrText

        foreach ($file in $files) {
            $i++
            $pbProgress.Value = $i
            $lblStatus.Text = "Processing $i of $total..."
            $form.Refresh()

            $ext = $file.Extension.ToLower()
            $target = $extMap[$ext]
            if (-not $target) { $target = "Other" }
            $catsUsed[$target] = $true

            $destDir = Join-Path $targetPath $target

            if (-not $isPreview) {
                if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
                $destFile = Join-Path $destDir $file.Name
                if (Test-Path $destFile) {
                    $base = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
                    $extPart = $file.Extension
                    $n = 1
                    do { $destFile = Join-Path $destDir ($base + "_$n" + $extPart); $n++ } while (Test-Path $destFile)
                }
                $global:undoLog += @{ Source = $file.FullName; Target = $destFile }
                Move-Item -Path $file.FullName -Destination $destFile
            }

            LogLine "  $($file.Name)" $clrText
            $rtbLog.SelectionStart = $rtbLog.TextLength - ($file.Name.Length + 3)
            $rtbLog.SelectionLength = 0
            LogLine "    -> $target" $clrSuccess
            $moved++
        }

        $script:lblStatMoved.Text = $moved.ToString()
        $script:lblStatSkip.Text  = $skipped.ToString()
        $script:lblStatCats.Text  = $catsUsed.Count.ToString()

        LogLine "" $clrText
        LogLine ("─" * 60) $clrBorder
        $doneMsg = if ($isPreview) { "Preview complete. $moved file(s) would be moved." } else { "Done! $moved file(s) organized." }
        LogLine "  $doneMsg" $clrSuccess
        $lblStatus.Text = $doneMsg
        
        if (-not $isPreview -and $moved -gt 0) {
            $btnUndo.Enabled = $true
        }
    }

    $btnOrganize.Enabled = $true
    $btnOrganize.Text = "Organize Now"
    $pbProgress.Value = 0
}

function Invoke-UndoOrganization {
    $btnUndo.Enabled = $false
    $btnOrganize.Enabled = $false
    
    $rtbLog.Clear()
    LogLine "Undoing last organize operation..." $clrAccent
    LogLine ("─" * 60) $clrBorder
    LogLine "" $clrText
    
    $lblStatus.Text = "Undoing moves..."
    $totalUndo = $global:undoLog.Count
    $pbProgress.Maximum = $totalUndo
    $i = 0
    $restored = 0
    
    # Iterate backwards so renamed _1, _2 collisions are handled in LIFO order
    for ($idx = $totalUndo - 1; $idx -ge 0; $idx--) {
        $item = $global:undoLog[$idx]
        $i++
        $pbProgress.Value = $i
        $form.Refresh()
        
        $srcFile = $item.Target
        $originalPath = $item.Source
        
        $fileName = [System.IO.Path]::GetFileName($srcFile)
        
        if (-not (Test-Path $srcFile)) {
            LogLine "  $fileName -> Skipped (missing)" [System.Drawing.Color]::FromArgb(251, 191, 36)
            continue
        }
        
        # Ensure the original directory still exists
        $originalDir = [System.IO.Path]::GetDirectoryName($originalPath)
        if (-not (Test-Path $originalDir)) { New-Item -ItemType Directory -Path $originalDir -Force | Out-Null }
        
        # Safety collision check (user placed a new file with same name there)
        $restoreTo = $originalPath
        if (Test-Path $restoreTo) {
            $base = [System.IO.Path]::GetFileNameWithoutExtension($originalPath)
            $extPart = [System.IO.Path]::GetExtension($originalPath)
            $n = 1
            do { $restoreTo = Join-Path $originalDir ($base + "_$n" + $extPart); $n++ } while (Test-Path $restoreTo)
            LogLine "  $fileName -> Collision. Restoring as $([System.IO.Path]::GetFileName($restoreTo))" [System.Drawing.Color]::FromArgb(251, 191, 36)
        }
        
        Move-Item -Path $srcFile -Destination $restoreTo
        LogLine "  $fileName -> Restored" $clrSuccess
        $restored++
    }
    
    $global:undoLog = @()
    
    LogLine "" $clrText
    LogLine ("─" * 60) $clrBorder
    LogLine "  Undo complete. $restored file(s) restored." $clrSuccess
    $lblStatus.Text = "Undo complete. $restored file(s) restored."
    
    # Update UI stats back to '0' since everything is undone, 
    # but we trigger a rescan to be accurate to the directory state.
    UpdateStats $txtPath.Text.Trim()
    
    $pbProgress.Value = 0
    $btnOrganize.Enabled = $true
}


# ── Main Form ──────────────────────────────────────────────────
$form = New-Object System.Windows.Forms.Form
$form.Text = "Folder Organizer"
$form.Size = New-Object System.Drawing.Size(680, 700)
$form.MinimumSize = New-Object System.Drawing.Size(680, 700)
$form.StartPosition = "CenterScreen"
$form.BackColor = $clrBg
$form.FormBorderStyle = "Sizable"
$form.MaximizeBox = $true
$form.Font = $fontInput
$form.Icon = [System.Drawing.SystemIcons]::Application

# ── Header Panel ───────────────────────────────────────────────
$pnlHeader = New-Object System.Windows.Forms.Panel
$pnlHeader.Dock = "Top"
$pnlHeader.Height = 80
$pnlHeader.BackColor = $clrSurface
$form.Controls.Add($pnlHeader)

# Accent bar at top of header
$pnlAccentBar = New-Object System.Windows.Forms.Panel
$pnlAccentBar.Dock = "Top"
$pnlAccentBar.Height = 3
$pnlAccentBar.BackColor = $clrAccent
$pnlHeader.Controls.Add($pnlAccentBar)

$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = "Folder Organizer"
$lblTitle.Font = $fontTitle
$lblTitle.ForeColor = $clrText
$lblTitle.Location = New-Object System.Drawing.Point(24, 14)
$lblTitle.Size = New-Object System.Drawing.Size(380, 36)
$lblTitle.BackColor = [System.Drawing.Color]::Transparent
$pnlHeader.Controls.Add($lblTitle)

$lblSub = New-Object System.Windows.Forms.Label
$lblSub.Text = "Intelligently sort files into categorized subfolders"
$lblSub.Font = $fontSub
$lblSub.ForeColor = $clrMuted
$lblSub.Location = New-Object System.Drawing.Point(26, 50)
$lblSub.Size = New-Object System.Drawing.Size(500, 18)
$lblSub.BackColor = [System.Drawing.Color]::Transparent
$pnlHeader.Controls.Add($lblSub)

# Version badge
$lblVersion = New-Object System.Windows.Forms.Label
$lblVersion.Text = "v2.0"
$lblVersion.Font = $fontSmall
$lblVersion.ForeColor = $clrAccent
$lblVersion.Location = New-Object System.Drawing.Point(610, 28)
$lblVersion.Size = New-Object System.Drawing.Size(40, 16)
$lblVersion.BackColor = [System.Drawing.Color]::Transparent
$pnlHeader.Controls.Add($lblVersion)

# ── Content Panel (scrollable area) ───────────────────────────
$pnlContent = New-Object System.Windows.Forms.Panel
$pnlContent.Dock = "Fill"
$pnlContent.BackColor = $clrBg
$pnlContent.AutoScroll = $false
$form.Controls.Add($pnlContent)

# ── Folder Path Section ────────────────────────────────────────
$lblPathHeader = New-Object System.Windows.Forms.Label
$lblPathHeader.Text = "TARGET FOLDER"
$lblPathHeader.Font = New-Object System.Drawing.Font("Segoe UI", 7.5, [System.Drawing.FontStyle]::Bold)
$lblPathHeader.ForeColor = $clrAccent
$lblPathHeader.Location = New-Object System.Drawing.Point(24, 24)
$lblPathHeader.Size = New-Object System.Drawing.Size(200, 16)
$lblPathHeader.BackColor = [System.Drawing.Color]::Transparent
$pnlContent.Controls.Add($lblPathHeader)

# Input row panel
$pnlInputRow = New-Object System.Windows.Forms.Panel
$pnlInputRow.Location = New-Object System.Drawing.Point(24, 44)
$pnlInputRow.Size = New-Object System.Drawing.Size(632, 42)
$pnlInputRow.Anchor = "Top, Left, Right"
$pnlInputRow.BackColor = $clrCard
$pnlContent.Controls.Add($pnlInputRow)

$txtPath = New-Object System.Windows.Forms.TextBox
$txtPath.Location = New-Object System.Drawing.Point(14, 10)
$txtPath.Size = New-Object System.Drawing.Size(490, 22)
$txtPath.Anchor = "Top, Left, Right"
$txtPath.BackColor = $clrCard
$txtPath.ForeColor = $clrText
$txtPath.BorderStyle = "None"
$txtPath.Font = $fontInput
$txtPath.Text = "Select or paste a folder path..."
$txtPath.ForeColor = $clrMuted
$pnlInputRow.Controls.Add($txtPath)

$txtPath.Add_Enter({
    if ($txtPath.Text -eq "Select or paste a folder path...") {
        $txtPath.Text = ""
        $txtPath.ForeColor = $clrText
    }
})
$txtPath.Add_Leave({
    if ($txtPath.Text -eq "") {
        $txtPath.Text = "Select or paste a folder path..."
        $txtPath.ForeColor = $clrMuted
    }
})

# Divider in input row
$pnlDivider = New-Object System.Windows.Forms.Panel
$pnlDivider.Location = New-Object System.Drawing.Point(508, 8)
$pnlDivider.Size = New-Object System.Drawing.Size(1, 26)
$pnlDivider.Anchor = "Top, Right"
$pnlDivider.BackColor = $clrBorder
$pnlInputRow.Controls.Add($pnlDivider)

$btnBrowse = New-Object System.Windows.Forms.Button
$btnBrowse.Text = "Browse"
$btnBrowse.Location = New-Object System.Drawing.Point(516, 7)
$btnBrowse.Size = New-Object System.Drawing.Size(108, 28)
$btnBrowse.Anchor = "Top, Right"
$btnBrowse.BackColor = $clrCard
$btnBrowse.ForeColor = $clrAccent
$btnBrowse.FlatStyle = "Flat"
$btnBrowse.FlatAppearance.BorderSize = 0
$btnBrowse.FlatAppearance.MouseOverBackColor = $clrBorder
$btnBrowse.Font = New-Object System.Drawing.Font("Segoe UI Semibold", 9, [System.Drawing.FontStyle]::Bold)
$btnBrowse.Cursor = [System.Windows.Forms.Cursors]::Hand
$pnlInputRow.Controls.Add($btnBrowse)

$btnBrowse.Add_Click({
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = "Select a folder to organize"
    if ($dialog.ShowDialog() -eq "OK") {
        $txtPath.Text = $dialog.SelectedPath
        $txtPath.ForeColor = $clrText
        UpdateStats $dialog.SelectedPath
    }
})

# ── Options Row ───────────────────────────────────────────────
$lblOptionsHeader = New-Object System.Windows.Forms.Label
$lblOptionsHeader.Text = "OPTIONS"
$lblOptionsHeader.Font = New-Object System.Drawing.Font("Segoe UI", 7.5, [System.Drawing.FontStyle]::Bold)
$lblOptionsHeader.ForeColor = $clrAccent
$lblOptionsHeader.Location = New-Object System.Drawing.Point(24, 102)
$lblOptionsHeader.Size = New-Object System.Drawing.Size(200, 16)
$lblOptionsHeader.BackColor = [System.Drawing.Color]::Transparent
$pnlContent.Controls.Add($lblOptionsHeader)

$pnlOptions = New-Object System.Windows.Forms.Panel
$pnlOptions.Location = New-Object System.Drawing.Point(24, 122)
$pnlOptions.Size = New-Object System.Drawing.Size(632, 44)
$pnlOptions.Anchor = "Top, Left, Right"
$pnlOptions.BackColor = $clrCard
$pnlContent.Controls.Add($pnlOptions)

$chkSubfolders = New-Object System.Windows.Forms.CheckBox
$chkSubfolders.Text = "Include files in subfolders"
$chkSubfolders.Font = $fontInput
$chkSubfolders.ForeColor = $clrText
$chkSubfolders.BackColor = [System.Drawing.Color]::Transparent
$chkSubfolders.Location = New-Object System.Drawing.Point(16, 12)
$chkSubfolders.Size = New-Object System.Drawing.Size(220, 22)
$chkSubfolders.FlatAppearance.CheckedBackColor = $clrAccent
$chkSubfolders.FlatAppearance.BorderColor = $clrBorder
$chkSubfolders.Cursor = [System.Windows.Forms.Cursors]::Hand
$pnlOptions.Controls.Add($chkSubfolders)

$pnlOptDivider = New-Object System.Windows.Forms.Panel
$pnlOptDivider.Location = New-Object System.Drawing.Point(248, 10)
$pnlOptDivider.Size = New-Object System.Drawing.Size(1, 24)
$pnlOptDivider.BackColor = $clrBorder
$pnlOptions.Controls.Add($pnlOptDivider)

$chkPreview = New-Object System.Windows.Forms.CheckBox
$chkPreview.Text = "Preview only (don't move files)"
$chkPreview.Font = $fontInput
$chkPreview.ForeColor = $clrText
$chkPreview.BackColor = [System.Drawing.Color]::Transparent
$chkPreview.Location = New-Object System.Drawing.Point(262, 12)
$chkPreview.Size = New-Object System.Drawing.Size(260, 22)
$chkPreview.FlatAppearance.CheckedBackColor = $clrAccent
$chkPreview.FlatAppearance.BorderColor = $clrBorder
$chkPreview.Cursor = [System.Windows.Forms.Cursors]::Hand
$pnlOptions.Controls.Add($chkPreview)

# ── Stats Row ─────────────────────────────────────────────────
$pnlStats = New-Object System.Windows.Forms.Panel
$pnlStats.Location = New-Object System.Drawing.Point(24, 182)
$pnlStats.Size = New-Object System.Drawing.Size(632, 68)
$pnlStats.Anchor = "Top, Left, Right"
$pnlStats.BackColor = $clrCard
$pnlContent.Controls.Add($pnlStats)

$script:lblStatFiles  = MakeStatBox $pnlStats 0   "0" "Total Files"
$script:lblStatMoved  = MakeStatBox $pnlStats 159 "0" "Moved"
$script:lblStatSkip   = MakeStatBox $pnlStats 318 "0" "Skipped"
$script:lblStatCats   = MakeStatBox $pnlStats 474 "0" "Categories"

$script:lblStatFiles.ForeColor  = $clrText
$script:lblStatMoved.ForeColor  = $clrSuccess
$script:lblStatSkip.ForeColor   = [System.Drawing.Color]::FromArgb(251, 191, 36)
$script:lblStatCats.ForeColor   = $clrAccent2

# ── Log Section ───────────────────────────────────────────────
$lblLogHeader = New-Object System.Windows.Forms.Label
$lblLogHeader.Text = "ACTIVITY LOG"
$lblLogHeader.Font = New-Object System.Drawing.Font("Segoe UI", 7.5, [System.Drawing.FontStyle]::Bold)
$lblLogHeader.ForeColor = $clrAccent
$lblLogHeader.Location = New-Object System.Drawing.Point(24, 266)
$lblLogHeader.Size = New-Object System.Drawing.Size(200, 16)
$lblLogHeader.BackColor = [System.Drawing.Color]::Transparent
$pnlContent.Controls.Add($lblLogHeader)

$rtbLog = New-Object System.Windows.Forms.RichTextBox
$rtbLog.Location = New-Object System.Drawing.Point(24, 286)
$rtbLog.Size = New-Object System.Drawing.Size(632, 199)
$rtbLog.BackColor = $clrLogBg
$rtbLog.ForeColor = $clrText
$rtbLog.Font = $fontLogFall
$rtbLog.BorderStyle = "None"
$rtbLog.ReadOnly = $true
$rtbLog.ScrollBars = "None"
$rtbLog.Anchor = "Top, Bottom, Left, Right"
$pnlContent.Controls.Add($rtbLog)

# ── Bottom Bar ────────────────────────────────────────────────
$pnlBottom = New-Object System.Windows.Forms.Panel
$pnlBottom.Dock = "Bottom"
$pnlBottom.Height = 72
$pnlBottom.BackColor = $clrSurface
$form.Controls.Add($pnlBottom)

# Progress bar inside bottom bar
$pbProgress = New-Object System.Windows.Forms.ProgressBar
$pbProgress.Location = New-Object System.Drawing.Point(24, 10)
$pbProgress.Size = New-Object System.Drawing.Size(632, 4)
$pbProgress.Anchor = "Top, Left, Right"
$pbProgress.Style = "Continuous"
$pbProgress.BackColor = $clrBorder
$pbProgress.ForeColor = $clrAccent
$pnlBottom.Controls.Add($pbProgress)

$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text = "Ready"
$lblStatus.Font = $fontSmall
$lblStatus.ForeColor = $clrMuted
$lblStatus.Location = New-Object System.Drawing.Point(26, 20)
$lblStatus.Size = New-Object System.Drawing.Size(300, 16)
$lblStatus.BackColor = [System.Drawing.Color]::Transparent
$pnlBottom.Controls.Add($lblStatus)

$btnUndo = New-Object System.Windows.Forms.Button
$btnUndo.Text = "Undo"
$btnUndo.Location = New-Object System.Drawing.Point(374, 16)
$btnUndo.Size = New-Object System.Drawing.Size(106, 42)
$btnUndo.Anchor = "Top, Right"
$btnUndo.BackColor = $clrCard
$btnUndo.ForeColor = $clrText
$btnUndo.FlatStyle = "Flat"
$btnUndo.FlatAppearance.BorderSize = 0
$btnUndo.FlatAppearance.MouseOverBackColor = $clrBorder
$btnUndo.Font = $fontBtn
$btnUndo.Cursor = [System.Windows.Forms.Cursors]::Hand
$btnUndo.Enabled = $false
$pnlBottom.Controls.Add($btnUndo)

$btnOrganize = New-Object System.Windows.Forms.Button
$btnOrganize.Text = "Organize Now"
$btnOrganize.Location = New-Object System.Drawing.Point(490, 16)
$btnOrganize.Size = New-Object System.Drawing.Size(166, 42)
$btnOrganize.Anchor = "Top, Right"
$btnOrganize.BackColor = $clrAccent
$btnOrganize.ForeColor = $clrBg
$btnOrganize.FlatStyle = "Flat"
$btnOrganize.FlatAppearance.BorderSize = 0
$btnOrganize.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(127, 200, 248)
$btnOrganize.Font = $fontBtn
$btnOrganize.Cursor = [System.Windows.Forms.Cursors]::Hand
$pnlBottom.Controls.Add($btnOrganize)

# ── Wire Up Events ─────────────────────────────────────────────
$btnOrganize.Add_Click({ Invoke-OrganizeFolder })
$btnUndo.Add_Click({ Invoke-UndoOrganization })

# ── Startup & Final Layout ────────────────────────────────────
# Ensure the content panel is correctly bounded between the 
# docked header and the docked footer, preventing overlap.
$pnlContent.BringToFront()

[void]$form.ShowDialog()