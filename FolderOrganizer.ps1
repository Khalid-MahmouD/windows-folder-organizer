Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$folderMap = @{
    "Documents\PDFs"       = @(".pdf")
    "Documents\Word"       = @(".doc",".docx")
    "Documents\Excel"      = @(".xls",".xlsx",".csv")
    "Documents\PowerPoint" = @(".ppt",".pptx")
    "Documents\Text"       = @(".txt",".rtf",".md")
    "Images"               = @(".jpg",".jpeg",".png",".gif",".bmp",".webp",".svg",".heic",".raw")
    "Videos"               = @(".mp4",".mov",".avi",".mkv",".wmv",".flv",".m4v",".webm")
    "Music"                = @(".mp3",".wav",".flac",".aac",".ogg",".wma",".m4a")
    "Installers"           = @(".exe",".msi",".msix",".appx",".dmg",".pkg",".deb",".rpm")
    "Compressed"           = @(".zip",".rar",".7z",".tar",".gz",".bz2",".xz")
    "Code"                 = @(".py",".js",".ts",".html",".css",".json",".xml",".sql",".sh",".bat",".ps1")
    "Fonts"                = @(".ttf",".otf",".woff",".woff2")
    "Torrents"             = @(".torrent")
}

$extMap = @{}
foreach ($folder in $folderMap.Keys) {
    foreach ($ext in $folderMap[$folder]) { $extMap[$ext] = $folder }
}

$form = New-Object System.Windows.Forms.Form
$form.Text = "Folder Organizer"
$form.Size = New-Object System.Drawing.Size(560, 420)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::FromArgb(245, 245, 250)

$title = New-Object System.Windows.Forms.Label
$title.Text = "Folder Organizer"
$title.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$title.ForeColor = [System.Drawing.Color]::FromArgb(50, 50, 120)
$title.Location = New-Object System.Drawing.Point(20, 20)
$title.Size = New-Object System.Drawing.Size(520, 40)
$form.Controls.Add($title)

$sub = New-Object System.Windows.Forms.Label
$sub.Text = "Select a folder to automatically sort files by type."
$sub.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$sub.ForeColor = [System.Drawing.Color]::Gray
$sub.Location = New-Object System.Drawing.Point(22, 60)
$sub.Size = New-Object System.Drawing.Size(520, 20)
$form.Controls.Add($sub)

$div = New-Object System.Windows.Forms.Label
$div.BorderStyle = "Fixed3D"
$div.Location = New-Object System.Drawing.Point(20, 88)
$div.Size = New-Object System.Drawing.Size(510, 2)
$form.Controls.Add($div)

$pathLabel = New-Object System.Windows.Forms.Label
$pathLabel.Text = "Folder Path:"
$pathLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$pathLabel.Location = New-Object System.Drawing.Point(22, 105)
$pathLabel.Size = New-Object System.Drawing.Size(100, 20)
$form.Controls.Add($pathLabel)

$pathBox = New-Object System.Windows.Forms.TextBox
$pathBox.Location = New-Object System.Drawing.Point(22, 128)
$pathBox.Size = New-Object System.Drawing.Size(390, 28)
$pathBox.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$pathBox.BorderStyle = "FixedSingle"
$form.Controls.Add($pathBox)

$browseBtn = New-Object System.Windows.Forms.Button
$browseBtn.Text = "Browse..."
$browseBtn.Location = New-Object System.Drawing.Point(422, 126)
$browseBtn.Size = New-Object System.Drawing.Size(108, 30)
$browseBtn.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$browseBtn.BackColor = [System.Drawing.Color]::FromArgb(70, 100, 200)
$browseBtn.ForeColor = [System.Drawing.Color]::White
$browseBtn.FlatStyle = "Flat"
$browseBtn.FlatAppearance.BorderSize = 0
$browseBtn.Add_Click({
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = "Select a folder to organize"
    if ($dialog.ShowDialog() -eq "OK") {
        $pathBox.Text = $dialog.SelectedPath
    }
})
$form.Controls.Add($browseBtn)

$optLabel = New-Object System.Windows.Forms.Label
$optLabel.Text = "Options:"
$optLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$optLabel.Location = New-Object System.Drawing.Point(22, 170)
$optLabel.Size = New-Object System.Drawing.Size(100, 20)
$form.Controls.Add($optLabel)

$chkSub = New-Object System.Windows.Forms.CheckBox
$chkSub.Text = "Include files in subfolders"
$chkSub.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$chkSub.Location = New-Object System.Drawing.Point(22, 193)
$chkSub.Size = New-Object System.Drawing.Size(220, 22)
$form.Controls.Add($chkSub)

$chkPreview = New-Object System.Windows.Forms.CheckBox
$chkPreview.Text = "Preview only (don't move files)"
$chkPreview.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$chkPreview.Location = New-Object System.Drawing.Point(260, 193)
$chkPreview.Size = New-Object System.Drawing.Size(240, 22)
$form.Controls.Add($chkPreview)

$logLabel = New-Object System.Windows.Forms.Label
$logLabel.Text = "Activity Log:"
$logLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$logLabel.Location = New-Object System.Drawing.Point(22, 225)
$logLabel.Size = New-Object System.Drawing.Size(100, 20)
$form.Controls.Add($logLabel)

$log = New-Object System.Windows.Forms.RichTextBox
$log.Location = New-Object System.Drawing.Point(22, 247)
$log.Size = New-Object System.Drawing.Size(508, 90)
$log.Font = New-Object System.Drawing.Font("Consolas", 8.5)
$log.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 40)
$log.ForeColor = [System.Drawing.Color]::FromArgb(180, 220, 180)
$log.ReadOnly = $true
$log.BorderStyle = "None"
$form.Controls.Add($log)

$status = New-Object System.Windows.Forms.Label
$status.Text = "Ready."
$status.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$status.ForeColor = [System.Drawing.Color]::Gray
$status.Location = New-Object System.Drawing.Point(22, 345)
$status.Size = New-Object System.Drawing.Size(400, 20)
$form.Controls.Add($status)

$goBtn = New-Object System.Windows.Forms.Button
$goBtn.Text = "Organize Now"
$goBtn.Location = New-Object System.Drawing.Point(390, 338)
$goBtn.Size = New-Object System.Drawing.Size(140, 34)
$goBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$goBtn.BackColor = [System.Drawing.Color]::FromArgb(40, 160, 80)
$goBtn.ForeColor = [System.Drawing.Color]::White
$goBtn.FlatStyle = "Flat"
$goBtn.FlatAppearance.BorderSize = 0

$goBtn.Add_Click({
    $targetPath = $pathBox.Text.Trim()
    if (-not $targetPath -or -not (Test-Path $targetPath)) {
        [System.Windows.Forms.MessageBox]::Show("Please enter a valid folder path.", "Invalid Folder", "OK", "Warning")
        return
    }
    $log.Clear()
    $moved = 0
    $skipped = 0
    $previewMode = $chkPreview.Checked
    $recurse = $chkSub.Checked
    $log.AppendText("$(if($previewMode){'[PREVIEW] '})Scanning: $targetPath`n")
    $status.Text = "Working..."
    $form.Refresh()
    $getArgs = @{ Path = $targetPath; File = $true }
    if ($recurse) { $getArgs["Recurse"] = $true }
    Get-ChildItem @getArgs | ForEach-Object {
        $ext    = $_.Extension.ToLower()
        $target = $extMap[$ext]
        if (-not $target) { $target = "Other" }
        if ($_.Name -match "Organize-" -or $_.Name -match "FolderOrganizer") { $skipped++; return }
        $destDir  = Join-Path $targetPath $target
        $destFile = Join-Path $destDir $_.Name
        if (Test-Path $destFile) {
            $base    = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
            $extPart = $_.Extension
            $i = 1
            do { $destFile = Join-Path $destDir ($base + "_$i" + $extPart); $i++ } while (Test-Path $destFile)
        }
        if (-not $previewMode) {
            if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
            Move-Item -Path $_.FullName -Destination $destFile
        }
        $log.SelectionColor = [System.Drawing.Color]::FromArgb(100, 200, 255)
        $log.AppendText("  $($_.Name)")
        $log.SelectionColor = [System.Drawing.Color]::FromArgb(180, 220, 180)
        $log.AppendText("  ->  $target`n")
        $moved++
        $form.Refresh()
    }
    $log.AppendText("`nDone! $moved file(s) $(if($previewMode){'would be organized'}else{'organized'}).")
    $status.Text = "$(if($previewMode){'Preview'}else{'Done'})! $moved file(s) $(if($previewMode){'would be moved'}else{'moved'})."
})
$form.Controls.Add($goBtn)

$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()
