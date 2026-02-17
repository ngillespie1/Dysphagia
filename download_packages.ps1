# SwallowSafe Package Downloader - Bypasses dart pub
# Downloads packages directly via HTTP and sets up pub cache

$PubCache = "$env:LOCALAPPDATA\Pub\Cache\hosted\pub.dev"
$TempDir = "$env:TEMP\pub_download"

# Create directories
New-Item -ItemType Directory -Path $PubCache -Force | Out-Null
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

# Core packages needed (simplified list - main packages)
$packages = @(
    @{name="equatable"; version="2.0.5"},
    @{name="http"; version="1.2.2"},
    @{name="intl"; version="0.19.0"},
    @{name="uuid"; version="4.5.1"},
    @{name="get_it"; version="7.7.0"},
    @{name="dio"; version="5.7.0"},
    @{name="path_provider"; version="2.1.5"},
    @{name="hive"; version="2.2.3"},
    @{name="hive_flutter"; version="1.1.0"},
    @{name="go_router"; version="14.6.2"},
    @{name="google_fonts"; version="6.2.1"},
    @{name="meta"; version="1.11.0"},
    @{name="collection"; version="1.18.0"},
    @{name="async"; version="2.11.0"},
    @{name="path"; version="1.9.0"},
    @{name="typed_data"; version="1.3.2"},
    @{name="http_parser"; version="4.0.2"},
    @{name="string_scanner"; version="1.2.0"},
    @{name="source_span"; version="1.10.0"},
    @{name="term_glyph"; version="1.2.1"},
    @{name="crypto"; version="3.0.3"},
    @{name="mocktail"; version="1.0.4"}
)

$ProgressPreference = 'SilentlyContinue'
$success = 0
$failed = 0

foreach ($pkg in $packages) {
    $name = $pkg.name
    $version = $pkg.version
    $url = "https://pub.dev/packages/$name/versions/$version.tar.gz"
    $dest = "$TempDir\$name-$version.tar.gz"
    $extractDir = "$PubCache\$name-$version"
    
    Write-Host "Downloading $name $version... " -NoNewline
    
    try {
        Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing -TimeoutSec 30
        
        # Extract using tar (built into Windows 10+)
        New-Item -ItemType Directory -Path $extractDir -Force | Out-Null
        tar -xzf $dest -C $extractDir 2>$null
        
        Write-Host "OK" -ForegroundColor Green
        $success++
    } catch {
        Write-Host "FAILED: $_" -ForegroundColor Red
        $failed++
    }
}

Write-Host ""
Write-Host "Downloaded: $success packages" -ForegroundColor Green
if ($failed -gt 0) {
    Write-Host "Failed: $failed packages" -ForegroundColor Red
}

# Cleanup temp
Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "Packages downloaded to: $PubCache"
Write-Host "Now try: dart pub get --offline"
