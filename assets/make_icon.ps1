Add-Type -AssemblyName System.Drawing

function Get-RoundedRect {
    param([System.Drawing.Rectangle]$rect, [int]$radius)
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $radius * 2
    $path.AddArc($rect.X, $rect.Y, $d, $d, 180, 90)
    $path.AddArc($rect.Right - $d, $rect.Y, $d, $d, 270, 90)
    $path.AddArc($rect.Right - $d, $rect.Bottom - $d, $d, $d, 0, 90)
    $path.AddArc($rect.X, $rect.Bottom - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    return $path
}

$size = 64
$bmp = New-Object System.Drawing.Bitmap($size, $size)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

$g.Clear([System.Drawing.Color]::Transparent)

# Colors
$clrBack = [System.Drawing.Color]::FromArgb(60, 140, 220)
$clrFront = [System.Drawing.Color]::FromArgb(99, 179, 237)

# Back Folder Tab
$tabRect = New-Object System.Drawing.Rectangle(4, 12, 28, 16)
$pathTab = Get-RoundedRect $tabRect 4
$bTab = New-Object System.Drawing.SolidBrush($clrBack)
$g.FillPath($bTab, $pathTab)

# Back Folder Body
$backRect = New-Object System.Drawing.Rectangle(4, 20, 56, 36)
$pathBack = Get-RoundedRect $backRect 4
$g.FillPath($bTab, $pathBack)

# Front Folder Tab
$frontRect = New-Object System.Drawing.Rectangle(4, 28, 56, 28)
$pathFront = Get-RoundedRect $frontRect 4
$bFront = New-Object System.Drawing.SolidBrush($clrFront)
$g.FillPath($bFront, $pathFront)

$iconHandle = $bmp.GetHicon()
$icon = [System.Drawing.Icon]::FromHandle($iconHandle)

$fs = New-Object System.IO.FileStream("C:\Users\PC\Documents\windows-folder-organizer\favicon.ico", [System.IO.FileMode]::Create)
$icon.Save($fs)
$fs.Close()

$bTab.Dispose()
$bFront.Dispose()
$pathTab.Dispose()
$pathBack.Dispose()
$pathFront.Dispose()
$g.Dispose()
$bmp.Dispose()
