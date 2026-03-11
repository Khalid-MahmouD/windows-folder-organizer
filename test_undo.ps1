Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Size = New-Object System.Drawing.Size(400, 150)
$form.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 26)

$btnOrganize = New-Object System.Windows.Forms.Button
$btnOrganize.Text = "Organize Now"
$btnOrganize.Location = New-Object System.Drawing.Point(200, 20)
$btnOrganize.Size = New-Object System.Drawing.Size(166, 42)
$btnOrganize.BackColor = [System.Drawing.Color]::FromArgb(99, 179, 237)
$btnOrganize.ForeColor = [System.Drawing.Color]::FromArgb(10, 10, 15)
$btnOrganize.FlatStyle = "Flat"
$btnOrganize.FlatAppearance.BorderSize = 0
$form.Controls.Add($btnOrganize)

$btnUndo = New-Object System.Windows.Forms.Button
$btnUndo.Text = "Undo"
$btnUndo.Location = New-Object System.Drawing.Point(100, 20)
$btnUndo.Size = New-Object System.Drawing.Size(80, 42)
$btnUndo.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 65)
$btnUndo.ForeColor = [System.Drawing.Color]::White
$btnUndo.FlatStyle = "Flat"
$btnUndo.FlatAppearance.BorderSize = 0
$form.Controls.Add($btnUndo)

$form.ShowDialog() | Out-Null
