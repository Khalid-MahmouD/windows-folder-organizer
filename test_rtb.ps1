Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Size = New-Object System.Drawing.Size(680, 640)
$form.MinimumSize = New-Object System.Drawing.Size(680, 640)
$form.StartPosition = "CenterScreen"

$pnlHeader = New-Object System.Windows.Forms.Panel
$pnlHeader.Dock = "Top"
$pnlHeader.Height = 80
$form.Controls.Add($pnlHeader)

$pnlBottom = New-Object System.Windows.Forms.Panel
$pnlBottom.Dock = "Bottom"
$pnlBottom.Height = 72
$form.Controls.Add($pnlBottom)

$pnlContent = New-Object System.Windows.Forms.Panel
$pnlContent.Dock = "Fill"
$form.Controls.Add($pnlContent)

$lblLogHeader = New-Object System.Windows.Forms.Label
$lblLogHeader.Text = "ACTIVITY LOG"
$lblLogHeader.Location = New-Object System.Drawing.Point(24, 266)
$pnlContent.Controls.Add($lblLogHeader)

$rtbLog = New-Object System.Windows.Forms.RichTextBox
$rtbLog.Location = New-Object System.Drawing.Point(24, 286)
$rtbLog.Size = New-Object System.Drawing.Size(632, 140)
$rtbLog.ScrollBars = "Vertical"
$pnlContent.Controls.Add($rtbLog)

$rtbLog.AppendText("Test`n" * 20)

# Anchor the controls so they resize with the window
$rtbLog.Anchor = "Top, Bottom, Left, Right"

Write-Host "Height of content area: $($pnlContent.Height)"
Write-Host "Bottom of RTB: $($rtbLog.Bottom)"

$form.ShowDialog() | Out-Null
