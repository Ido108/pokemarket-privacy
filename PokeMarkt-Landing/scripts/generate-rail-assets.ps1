param(
  [string]$DbZip = "C:\Users\ido\REPOS\tcg-server\data\tcg.db.seed.zip",
  [string]$OutDir = "assets\rail",
  [int]$CardCount = 45,
  [int]$ProductCount = 25,
  [int]$MinProductBytes = 12000
)

$ErrorActionPreference = "Stop"

$workDir = Join-Path $env:TEMP "pokemarkt-landing-db"
$dbPath = Join-Path $workDir "tcg.db.seed"

if (Test-Path -LiteralPath $workDir) {
  Remove-Item -LiteralPath $workDir -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $workDir | Out-Null
Expand-Archive -LiteralPath $DbZip -DestinationPath $workDir -Force

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$cardSql = @"
SELECT name, image_url, 'card' AS kind
FROM products
WHERE image_url != ''
  AND is_card = 1
  AND (
    image_url LIKE 'https://images.pokemontcg.io/%'
    OR image_url LIKE 'https://assets.tcgdex.net/%'
    OR image_url LIKE 'https://images.scrydex.com/%'
  )
ORDER BY random()
LIMIT $CardCount;
"@

$productSql = @"
SELECT title AS name, url, image_url, 'product' AS kind
FROM pricecharting_products
WHERE image_url != ''
  AND lower(title) NOT LIKE '%#%'
  AND lower(title) NOT LIKE '%prize pack%'
  AND (
    lower(title) LIKE '%booster box%'
    OR lower(title) LIKE '%elite trainer box%'
    OR lower(title) LIKE '%collection box%'
    OR lower(title) LIKE '%booster pack%'
    OR lower(title) LIKE '% tin%'
    OR lower(title) LIKE '%blister pack%'
  )
ORDER BY random()
LIMIT $($ProductCount * 6);
"@

$cards = sqlite3 -json $dbPath $cardSql | ConvertFrom-Json
$productCandidates = sqlite3 -json $dbPath $productSql | ConvertFrom-Json

Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Runtime.InteropServices;

public static class RailProductCleaner {
  static bool IsBg(byte r, byte g, byte b, byte a) {
    if (a < 16) return true;
    int max = Math.Max(r, Math.Max(g, b));
    int min = Math.Min(r, Math.Min(g, b));
    int avg = (r + g + b) / 3;
    if (avg > 218 && (max - min) < 62) return true;
    if (avg < 40 && (max - min) < 48) return true;
    return false;
  }

  public static void Clean(string inputPath, string outputPath) {
    using (Bitmap original = new Bitmap(inputPath))
    using (Bitmap bmp = new Bitmap(original.Width, original.Height, PixelFormat.Format32bppArgb)) {
      using (Graphics draw = Graphics.FromImage(bmp)) draw.DrawImage(original, 0, 0, original.Width, original.Height);
      int w = bmp.Width, h = bmp.Height, len = w * h;
      Rectangle rect = new Rectangle(0, 0, w, h);
      BitmapData data = bmp.LockBits(rect, ImageLockMode.ReadWrite, PixelFormat.Format32bppArgb);
      int bytes = Math.Abs(data.Stride) * h;
      byte[] px = new byte[bytes];
      Marshal.Copy(data.Scan0, px, 0, bytes);
      bool[] seen = new bool[len];
      int[] queue = new int[len];
      int head = 0, tail = 0;
      Action<int,int> add = (x,y) => {
        if (x < 0 || y < 0 || x >= w || y >= h) return;
        int id = y * w + x;
        if (seen[id]) return;
        seen[id] = true;
        int o = y * data.Stride + x * 4;
        if (IsBg(px[o+2], px[o+1], px[o], px[o+3])) queue[tail++] = id;
      };
      for (int x = 0; x < w; x++) { add(x, 0); add(x, h - 1); }
      for (int y = 0; y < h; y++) { add(0, y); add(w - 1, y); }
      while (head < tail) {
        int id = queue[head++];
        int x = id % w, y = id / w;
        int o = y * data.Stride + x * 4;
        px[o+3] = 0;
        add(x - 1, y); add(x + 1, y); add(x, y - 1); add(x, y + 1);
      }
      int minX = w, minY = h, maxX = -1, maxY = -1;
      for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
          int o = y * data.Stride + x * 4;
          if (px[o+3] > 12) {
            if (x < minX) minX = x; if (x > maxX) maxX = x;
            if (y < minY) minY = y; if (y > maxY) maxY = y;
          }
        }
      }
      Marshal.Copy(px, 0, data.Scan0, bytes);
      bmp.UnlockBits(data);
      if (maxX <= minX || maxY <= minY) throw new Exception("No foreground pixels found.");
      int pad = 8;
      minX = Math.Max(0, minX - pad); minY = Math.Max(0, minY - pad);
      maxX = Math.Min(w - 1, maxX + pad); maxY = Math.Min(h - 1, maxY + pad);
      int cw = maxX - minX + 1, ch = maxY - minY + 1;
      using (Bitmap crop = new Bitmap(cw, ch, PixelFormat.Format32bppArgb)) {
        using (Graphics g = Graphics.FromImage(crop)) {
          g.Clear(Color.Transparent);
          g.DrawImage(bmp, new Rectangle(0, 0, cw, ch), new Rectangle(minX, minY, cw, ch), GraphicsUnit.Pixel);
        }
        crop.Save(outputPath, ImageFormat.Png);
      }
    }
  }
}
"@

$manifest = @()
$i = 1
foreach ($item in $cards) {
  $ext = ".png"
  if ($item.image_url -match "\.webp($|\?)") { $ext = ".webp" }
  if ($item.image_url -match "\.jpg($|\?)") { $ext = ".jpg" }
  if ($item.image_url -match "\.jpeg($|\?)") { $ext = ".jpg" }

  $fileName = "{0}-{1:D2}{2}" -f $item.kind, $i, $ext
  $filePath = Join-Path $OutDir $fileName
  & curl.exe -L -s -A "Mozilla/5.0" -o $filePath $item.image_url
  if (-not (Test-Path -LiteralPath $filePath) -or (Get-Item -LiteralPath $filePath).Length -lt 10000) {
    if (Test-Path -LiteralPath $filePath) { Remove-Item -LiteralPath $filePath -Force }
    continue
  }

  $manifest += [pscustomobject]@{
    file = ($filePath -replace "\\", "/")
    name = $item.name
    kind = $item.kind
    source = $item.image_url
  }
  $i++
}

$acceptedProducts = 0
foreach ($item in $productCandidates) {
  if ($acceptedProducts -ge $ProductCount) { break }

  $sourceUrl = $item.image_url
  if ($item.url) {
    try {
      $html = & curl.exe -L -s -A "Mozilla/5.0" $item.url
      $matches = [regex]::Matches($html, 'https://storage\.googleapis\.com/images\.pricecharting\.com/[^"''\s<>]+/1600\.jpg')
      if ($matches.Count -gt 0) {
        $sourceUrl = $matches[0].Value
      } else {
        $sourceUrl = $sourceUrl -replace '/60\.jpg$', '/1600.jpg'
      }
    } catch {
      $sourceUrl = $sourceUrl -replace '/60\.jpg$', '/1600.jpg'
    }
  } else {
    $sourceUrl = $sourceUrl -replace '/60\.jpg$', '/1600.jpg'
  }

  $fileName = "product-{0:D2}.png" -f ($acceptedProducts + 1)
  $filePath = Join-Path $OutDir $fileName
  $rawPath = Join-Path $OutDir ("product-{0:D2}-raw.jpg" -f ($acceptedProducts + 1))
  try {
    & curl.exe -L -s -A "Mozilla/5.0" -o $rawPath $sourceUrl
    $bytes = (Get-Item -LiteralPath $rawPath).Length
    if ($bytes -lt $MinProductBytes) {
      Remove-Item -LiteralPath $rawPath -Force
      continue
    }
    [RailProductCleaner]::Clean($rawPath, $filePath)
    Remove-Item -LiteralPath $rawPath -Force

    $manifest += [pscustomObject]@{
      file = ($filePath -replace "\\", "/")
      name = $item.name
      kind = "product"
      source = $sourceUrl
    }
    $acceptedProducts++
  } catch {
    if (Test-Path -LiteralPath $rawPath) {
      Remove-Item -LiteralPath $rawPath -Force
    }
    if (Test-Path -LiteralPath $filePath) {
      Remove-Item -LiteralPath $filePath -Force
    }
  }
}

$manifest | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $OutDir "manifest.json") -Encoding UTF8
Write-Host "Generated $($manifest.Count) rail assets in $OutDir"
