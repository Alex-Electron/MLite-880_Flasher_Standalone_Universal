$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$out = Join-Path $root 'dist'
New-Item -ItemType Directory -Force -Path $out | Out-Null
$qmk = Join-Path $root 'qmk_driver_installer.exe'
$zadig = Join-Path $root 'tools/zadig-2.9.exe'
if ((Get-FileHash $qmk -Algorithm SHA256).Hash -ne 'CCD78A40E3DB74A189F42E3EAB93463EF6C214C4F928B586992D70863B094431') { throw 'QMK hash mismatch' }
if ((Get-FileHash $zadig -Algorithm SHA256).Hash -ne '4ECAA95DF3DA3621486A043AEF8B3050B8BAFE7C901402871E816229EF82039B') { throw 'Zadig hash mismatch' }
$compiler = Join-Path $env:WINDIR 'Microsoft.NET/Framework64/v4.0.30319/csc.exe'
$exe = Join-Path $out 'Malahit-STM32-DFU-Setup.exe'
$source = Join-Path $PSScriptRoot 'Setup.cs'
$gpl = Join-Path $PSScriptRoot 'COPYING'
$lgpl = Join-Path $PSScriptRoot 'COPYING-LGPL'
foreach ($file in @($compiler, $source, $gpl, $lgpl)) { if (!(Test-Path -LiteralPath $file)) { throw "Missing build input: $file" } }
& $compiler /nologo /target:winexe /platform:anycpu /optimize+ /codepage:65001 "/out:$exe" /reference:System.Windows.Forms.dll /reference:System.Drawing.dll /reference:System.Management.dll "/resource:$qmk,qmk.exe" "/resource:$zadig,zadig.exe" "/resource:$gpl,COPYING" "/resource:$lgpl,COPYING-LGPL" $source
if ($LASTEXITCODE -ne 0) { throw 'Compilation failed' }
$test = Start-Process -FilePath $exe -ArgumentList '--self-test' -Wait -PassThru
if ($test.ExitCode -ne 0) { throw 'Installer self-test failed' }
$hash = (Get-FileHash $exe -Algorithm SHA256).Hash.ToLowerInvariant()
[IO.File]::WriteAllText((Join-Path $out 'Malahit-STM32-DFU-Setup.exe.sha256'), "$hash  Malahit-STM32-DFU-Setup.exe`n", [Text.Encoding]::ASCII)
Write-Host "Built and self-tested: $exe SHA256=$hash"
