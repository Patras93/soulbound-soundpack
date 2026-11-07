# Soulbound Soundpack v1.6.3 — przeslij kod i OGG, GitHub Actions publikuje Release.
& {
    $ErrorActionPreference = 'Stop'
    $repo = 'Patras93/soulbound-soundpack'
    $root = Split-Path -Parent $PSCommandPath
    $tag = 'v1.6.3'
    $repoUrl = 'https://github.com/Patras93/soulbound-soundpack.git'
    $dest = Join-Path ([IO.Path]::GetTempPath()) ('SoulboundGit-' + [guid]::NewGuid().ToString('N'))
    try {
        if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw 'Brak Git for Windows.' }
        if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { throw 'Brak GitHub CLI.' }
        foreach ($f in @('pack.toml','soundpack.lua','README_PL.txt','CHANGELOG_PL.txt','.github\workflows\release.yml','.github\scripts\build_release.py','.github\tests\test_announce.lua','.github\tests\test_v163.lua','.github\tests\test_lupa_syntax.py')) {
            if (-not (Test-Path -LiteralPath (Join-Path $root $f) -PathType Leaf)) { throw "Brak $f" }
        }
        $sounds = @(Get-ChildItem -LiteralPath (Join-Path $root 'sounds') -Recurse -File -Filter '*.ogg')
        if ($sounds.Count -ne 87) { throw "Zla liczba OGG: $($sounds.Count); powinno byc 87. Rozpakuj caly ZIP." }
        $manifest = [IO.File]::ReadAllText((Join-Path $root 'pack.toml'))
        if (-not $manifest.Contains(('version = "' + $tag.Substring(1) + '"'))) { throw ('Nieprawidlowa wersja pack.toml. Oczekiwano: ' + $tag.Substring(1)) }
        if (-not $manifest.Contains('origin = "https://github.com/Patras93/soulbound-soundpack/releases/latest/download/Soulbound-Soundpack.zip"')) { throw 'Bledny origin updatera.' }
        & gh auth status *> $null
        if ($LASTEXITCODE -ne 0) {
            Write-Host 'Zaloguj sie do GitHub przez przegladarke.'
            & gh auth login --hostname github.com --git-protocol https --web
            if ($LASTEXITCODE -ne 0) { throw 'Logowanie do GitHub nie powiodlo sie.' }
        }
        & gh auth setup-git
        if ($LASTEXITCODE -ne 0) { throw 'Blad konfiguracji GitHub CLI.' }
        & git clone --quiet $repoUrl $dest
        if ($LASTEXITCODE -ne 0) { throw 'Nie udalo sie sklonowac repozytorium.' }
        # Nowe OGG i pliki projektu bez usuwania obcych plikow repozytorium.
        Get-ChildItem -LiteralPath $root -File | Where-Object { $_.Name -in @('soundpack.lua','pack.toml','README.md','README_PL.txt','CHANGELOG_PL.txt','PUBLIKUJ_NA_GITHUB.cmd','PUBLIKUJ_NA_GITHUB.ps1') } | ForEach-Object {
            Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $dest $_.Name) -Force
        }
        Get-ChildItem -LiteralPath (Join-Path $root 'sounds') -Recurse -File | ForEach-Object {
            $relative = $_.FullName.Substring($root.Length + 1)
            $target = Join-Path $dest $relative
            $parent = Split-Path -Parent $target
            if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
            Copy-Item -LiteralPath $_.FullName -Destination $target -Force
        }
        # Usuń wyłącznie przestarzały test v1.5.9; nowe testy v1.6.3 go zastępują.
        $oldTest = Join-Path $dest '.github\tests\test_soundpack.lua'
        if (Test-Path -LiteralPath $oldTest -PathType Leaf) { Remove-Item -LiteralPath $oldTest -Force }
        Get-ChildItem -LiteralPath (Join-Path $root '.github') -Recurse -File | ForEach-Object {
            $relative = $_.FullName.Substring($root.Length + 1)
            $target = Join-Path $dest $relative
            $parent = Split-Path -Parent $target
            if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
            Copy-Item -LiteralPath $_.FullName -Destination $target -Force
        }
        & git -C $dest config user.name 'Patras93'
        & git -C $dest config user.email '93275458+Patras93@users.noreply.github.com'
        & git -C $dest add -A -- pack.toml soundpack.lua sounds README.md README_PL.txt CHANGELOG_PL.txt PUBLIKUJ_NA_GITHUB.cmd PUBLIKUJ_NA_GITHUB.ps1 .github
        if ($LASTEXITCODE -ne 0) { throw 'Blad git add.' }
        & git -C $dest diff --cached --quiet
        if ($LASTEXITCODE -eq 1) {
            & git -C $dest commit --quiet -m 'Soulbound Soundpack v1.6.3 - 87 OGG, wydarzenia, kroki, Soul Level'
            if ($LASTEXITCODE -ne 0) { throw 'Blad git commit.' }
            & git -C $dest push --quiet origin HEAD:main
            if ($LASTEXITCODE -ne 0) { throw 'Blad git push. Niczego nie publikuj recznie.' }
            Write-Host 'SUKCES: v1.6.3 wyslane do GitHub. Release utworzy GitHub Actions.'
        } elseif ($LASTEXITCODE -eq 0) {
            Write-Host 'Pliki sa juz identyczne z repozytorium; sprawdz istniejący Release.'
        } else { throw 'Blad git diff.' }
        Write-Host "Actions: https://github.com/$repo/actions"
        Write-Host "Releases: https://github.com/$repo/releases"
    } catch {
        Write-Host ('BLAD: ' + $_.Exception.Message)
        Write-Host 'Zachowaj rozpakowana paczke. W razie problemu niczego nie usuwaj.'
    } finally {
        if (Test-Path -LiteralPath $dest) { Remove-Item -LiteralPath $dest -Recurse -Force -ErrorAction SilentlyContinue }
    }
}
