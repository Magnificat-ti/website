param(
    [string]$FolderImages,
    [string]$IndexFile
)

$d = [char]60   # <
$g = [char]62   # >

$folder = $FolderImages.Split(',')
$enc = New-Object System.Text.UTF8Encoding($false)
$c = [IO.File]::ReadAllText($IndexFile, $enc)
$marker = $d + '!-- BANNER_SLIDES_END --' + $g
$rxImg = 'banner_images/([\w\.]+)'

# 1. Remover slides de imagens ausentes na pasta
$existing = [regex]::Matches($c, $rxImg) | ForEach-Object { $_.Groups[1].Value }
$toRemove = @($existing | Where-Object { $_ -notin $folder })

foreach ($fn in $toRemove) {
    $search = 'banner_images/' + $fn
    do {
        $idx = $c.IndexOf($search)
        if ($idx -ge 0) {
            $before = $c.Substring(0, $idx)
            $after = $c.Substring($idx)

            $divStart = $before.LastIndexOf($d + 'div class=')
            if ($divStart -lt 0) { $divStart = $before.LastIndexOf($d + 'div') }

            $divEnd = $after.IndexOf($d + '/div' + $g)
            if ($divEnd -ge 0) {
                $fullLen = $idx + $divEnd + ($d + '/div' + $g).Length - $divStart
                $c = $c.Remove($divStart, $fullLen)
                Write-Host "Removido: $fn"
            }
        }
    } while ($idx -ge 0 -and $divEnd -ge 0)
}

# 2. Adicionar slides de imagens novas
$existingAfter = [regex]::Matches($c, $rxImg) | ForEach-Object { $_.Groups[1].Value }
$newSlides = ''
foreach ($img in $folder) {
    if ($img -notin $existingAfter) {
        $s = '                ' + $d + 'div class="swiper-slide"' + $g + [char]10
        $s += '                   ' + $d + 'img class="carousel_img" src="./images/banner_images/' + $img + '" alt="' + $img + '"' + $g + [char]10
        $s += '                ' + $d + '/div' + $g + [char]10
        $newSlides += $s
        Write-Host "Adicionado: $img"
    }
}

$p = $c.IndexOf($marker)
if ($p -ge 0 -and $newSlides) { $c = $c.Insert($p, $newSlides) }

# 3. Gravar
[IO.File]::WriteAllText($IndexFile, $c, $enc)
