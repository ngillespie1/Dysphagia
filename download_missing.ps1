$ProgressPreference = 'SilentlyContinue'
$cacheRoot = "$env:LOCALAPPDATA\Pub\Cache\hosted\pub.dev"

# More packages needed
$packages = @(
    "bloc_test-9.1.7", "bloc-8.1.4", "diff_match_patch-0.4.1", 
    "flutter_lints-5.0.0", "lints-5.1.1",
    "purchases_flutter-8.3.0", "flutter_local_notifications-18.0.1",
    "video_player-2.9.2", "firebase_core-3.8.0", "firebase_auth-5.5.0",
    "cloud_firestore-5.6.0", "firebase_messaging-15.2.0",
    "firebase_core_platform_interface-5.4.0", "firebase_auth_platform_interface-7.4.0",
    "cloud_firestore_platform_interface-6.6.0", "firebase_messaging_platform_interface-4.6.0",
    "video_player_platform_interface-6.2.3", "purchases_flutter_platform_interface-3.0.0",
    "flutter_local_notifications_platform_interface-7.3.0",
    "stream_transform-2.1.0", "rxdart-0.28.0", "clock-1.1.1",
    "fake_async-1.3.2", "matcher-0.12.16"
)

$success = 0; $failed = 0

foreach ($p in $packages) {
    $parts = $p -split '-(?=\d)'
    $name = $parts[0]
    $ver = $parts[1]
    $url = "https://pub.dev/packages/$name/versions/$ver.tar.gz"
    $dest = "$env:TEMP\$p.tar.gz"
    $pkgDir = "$cacheRoot\$p"
    
    Write-Host "[$name $ver] " -NoNewline
    
    try {
        Remove-Item $pkgDir -Recurse -Force -ErrorAction SilentlyContinue
        New-Item -ItemType Directory $pkgDir -Force | Out-Null
        Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing -TimeoutSec 30
        Push-Location $pkgDir
        tar -xzf $dest 2>$null
        Pop-Location
        if (Test-Path "$pkgDir\pubspec.yaml") {
            Write-Host "OK" -ForegroundColor Green
            $success++
        } else {
            Write-Host "EMPTY" -ForegroundColor Yellow
            $failed++
        }
        Remove-Item $dest -Force -ErrorAction SilentlyContinue
    } catch {
        Write-Host "FAIL" -ForegroundColor Red
        $failed++
    }
}

Write-Host "`nDone: $success OK, $failed failed"
