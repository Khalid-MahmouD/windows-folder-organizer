Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Size = New-Object System.Drawing.Size(680, 620)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(10, 10, 15)

$pnlHeader = New-Object System.Windows.Forms.Panel
$pnlHeader.Dock = "Top"
$pnlHeader.Height = 80
$pnlHeader.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 26)
$form.Controls.Add($pnlHeader)

$pnlBottom = New-Object System.Windows.Forms.Panel
$pnlBottom.Dock = "Bottom"
$pnlBottom.Height = 72
$pnlBottom.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 26)
$form.Controls.Add($pnlBottom)

$pnlContent = New-Object System.Windows.Forms.Panel
$pnlContent.Dock = "Fill"
$pnlContent.AutoScroll = $true
$pnlContent.BackColor = [System.Drawing.Color]::FromArgb(26, 26, 38)
$form.Controls.Add($pnlContent)

$lblLogHeader = New-Object System.Windows.Forms.Label
$lblLogHeader.Text = "ACTIVITY LOG"
$lblLogHeader.Location = New-Object System.Drawing.Point(24, 266)
$lblLogHeader.ForeColor = [System.Drawing.Color]::White
$pnlContent.Controls.Add($lblLogHeader)

$rtbLog = New-Object System.Windows.Forms.RichTextBox
$rtbLog.Location = New-Object System.Drawing.Point(24, 286)
$rtbLog.Size = New-Object System.Drawing.Size(632, 100)
$rtbLog.Anchor = "Top, Bottom, Left, Right"
$rtbLog.BackColor = [System.Drawing.Color]::Gray
$pnlContent.Controls.Add($rtbLog)

$pnlContent.BringToFront()

$form.ShowDialog() | Out-Null
