Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Size = New-Object System.Drawing.Size(680, 620)
$form.BackColor = [System.Drawing.Color]::FromArgb(10, 10, 15)
$form.FormBorderStyle = "Sizable"

$pnlHeader = New-Object System.Windows.Forms.Panel
$pnlHeader.Dock = "Top"
$pnlHeader.Height = 80
$pnlHeader.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 26)
$form.Controls.Add($pnlHeader)

$pnlBottom = New-Object System.Windows.Forms.Panel
$pnlBottom.Dock = "Bottom"
$pnlBottom.Height = 72
$pnlBottom.BackColor = [System.Drawing.Color]::Red
$form.Controls.Add($pnlBottom)

$btnOrganize = New-Object System.Windows.Forms.Button
$btnOrganize.Text = "Organize Now"
$btnOrganize.Location = New-Object System.Drawing.Point(490, 16)
$btnOrganize.Size = New-Object System.Drawing.Size(166, 42)
$btnOrganize.BackColor = [System.Drawing.Color]::Blue
$pnlBottom.Controls.Add($btnOrganize)

$pnlContent = New-Object System.Windows.Forms.Panel
$pnlContent.Dock = "Fill"
$pnlContent.BackColor = [System.Drawing.Color]::Green
$form.Controls.Add($pnlContent)

# If we don't bring to front, it might overlap? Let's check.
$pnlContent.BringToFront()

$form.ShowDialog() | Out-Null
