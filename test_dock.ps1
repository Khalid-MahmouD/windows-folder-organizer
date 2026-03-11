Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Size = New-Object System.Drawing.Size(400, 300)

$pnlHeader = New-Object System.Windows.Forms.Panel
$pnlHeader.Dock = "Top"
$pnlHeader.Height = 50
$pnlHeader.BackColor = [System.Drawing.Color]::Blue
$form.Controls.Add($pnlHeader)

$pnlContent = New-Object System.Windows.Forms.Panel
$pnlContent.Dock = "Fill"
$pnlContent.BackColor = [System.Drawing.Color]::Green
$form.Controls.Add($pnlContent)

$pnlBottom = New-Object System.Windows.Forms.Panel
$pnlBottom.Dock = "Bottom"
$pnlBottom.Height = 50
$pnlBottom.BackColor = [System.Drawing.Color]::Red
$form.Controls.Add($pnlBottom)

# Fix the dock order
$pnlContent.BringToFront()

$form.ShowDialog() | Out-Null
