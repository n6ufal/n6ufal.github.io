param(
    [int]$MaxWidth = 1200,
    [int]$Quality = 85,
    [string[]]$TargetDirs = @(
        (Resolve-Path "$PSScriptRoot/../content"),
        (Resolve-Path "$PSScriptRoot/../assets")
    )
)

$processed = @{ total = 0; savedBytes = [long]0 }

Add-Type -AssemblyName System.Drawing
$jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
if (-not $jpegCodec) { Write-Error "JPEG encoder not found"; exit 1 }

$TargetDirs | ForEach-Object {
    $dir = $_
    Get-ChildItem -LiteralPath $dir -Recurse -Include *.jpg,*.jpeg,*.png -File | ForEach-Object {
        $path = $_.FullName
        $ext = $_.Extension.ToLower()
        $len = $_.Length

        $stream = [System.IO.File]::OpenRead($path)
        $img = [System.Drawing.Image]::FromStream($stream)
        $stream.Close()

        $w = $img.Width
        $h = $img.Height
        $needsResize = $w -gt $MaxWidth
        $isPng = $ext -eq ".png"

        if (-not $needsResize -and -not $isPng) {
            $img.Dispose()
            return
        }

        $newW = if ($needsResize) { $MaxWidth } else { $w }
        $newH = if ($needsResize) { [int]($h * ($MaxWidth / $w)) } else { $h }

        $bitmap = New-Object System.Drawing.Bitmap($newW, $newH)
        $g = [System.Drawing.Graphics]::FromImage($bitmap)
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.DrawImage($img, 0, 0, $newW, $newH)
        $g.Dispose()
        $img.Dispose()

        $encParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
        $encParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [int64]$Quality)

        $tmpPath = [System.IO.Path]::GetTempFileName()
        $bitmap.Save($tmpPath, $jpegCodec, $encParams)
        $bitmap.Dispose()

        if ($isPng) { Remove-Item -LiteralPath $path -Force }

        $finalPath = [System.IO.Path]::ChangeExtension($path, ".jpg")
        Move-Item -LiteralPath $tmpPath -Destination $finalPath -Force

        $newSize = (Get-Item $finalPath).Length
        $saved = $len - $newSize
        $processed.total++
        $processed.savedBytes += $saved

        Write-Output "$(Resolve-Path $finalPath -RelativeBase $dir): ${w}x${h} → ${newW}x${newH}, $([math]::Round($len/1KB)) KB → $([math]::Round($newSize/1KB)) KB ($([math]::Round($saved/1KB)) KB saved)"
    }
}

Write-Output "`nDone. $($processed.total) images processed, $([math]::Round($processed.savedBytes/1MB, 2)) MB saved."
