$ProgressPreference = 'SilentlyContinue'
$cacheRoot = "$env:LOCALAPPDATA\Pub\Cache\hosted\pub.dev"

# All packages needed for swallow_safe
$packages = @(
    "equatable-2.0.5", "http-1.2.2", "intl-0.19.0", "uuid-4.5.1", "get_it-7.7.0",
    "dio-5.7.0", "hive-2.2.3", "hive_flutter-1.1.0", "go_router-14.6.2",
    "google_fonts-6.2.1", "meta-1.15.0", "collection-1.18.0", "async-2.11.0",
    "path-1.9.0", "typed_data-1.3.2", "http_parser-4.0.2", "string_scanner-1.2.0",
    "source_span-1.10.0", "term_glyph-1.2.1", "crypto-3.0.3", "mocktail-1.0.4",
    "bloc-8.1.4", "flutter_bloc-8.1.6", "provider-6.1.2", "nested-1.0.0",
    "path_provider_platform_interface-2.1.2", "plugin_platform_interface-2.1.8",
    "ffi-2.1.4", "flutter_animate-4.5.2", "flutter_svg-2.0.16", "vector_graphics-1.1.15",
    "vector_graphics_codec-1.1.12", "vector_graphics_compiler-1.1.16"
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
        # Clean and create dir
        Remove-Item $pkgDir -Recurse -Force -ErrorAction SilentlyContinue
        New-Item -ItemType Directory $pkgDir -Force | Out-Null
        
        # Download
        Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing -TimeoutSec 30
        
        # Extract
        Push-Location $pkgDir
        tar -xzf $dest 2>$null
        Pop-Location
        
        # Verify
        if (Test-Path "$pkgDir\pubspec.yaml") {
            Write-Host "OK" -ForegroundColor Green
            $success++
        } else {
            Write-Host "EMPTY" -ForegroundColor Yellow
            $failed++
        }
        
        Remove-Item $dest -Force -ErrorAction SilentlyContinue
    } catch {
        Write-Host "FAIL: $($_.Exception.Message)" -ForegroundColor Red
        $failed++
    }
}

Write-Host "`nDone: $success OK, $failed failed"
