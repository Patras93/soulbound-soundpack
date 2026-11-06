# Soulbound Soundpack v1.5.7 - publikacja w repozytorium i wydanie GitHub Releases
# Uruchom na Windows po rozpakowaniu calego ZIP-a.
& {
    $ErrorActionPreference = 'Stop'
    $repo = 'Patras93/soulbound-soundpack'
    $root = Split-Path -Parent $PSCommandPath
    $tag = 'v1.5.7'
    $dest = Join-Path ([IO.Path]::GetTempPath()) ('SoulboundGithub-' + [guid]::NewGuid().ToString('N'))
    $repoUrl = 'https://github.com/Patras93/soulbound-soundpack.git'
    try {
        if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
            throw 'Brak Git for Windows. Zainstaluj: winget install --id Git.Git -e'
        }
        if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
            throw 'Brak GitHub CLI. Zainstaluj: winget install --id GitHub.cli -e'
        }
        foreach ($f in @('pack.toml', 'soundpack.lua', 'README_PL.txt', 'CHANGELOG_PL.txt', '.github\workflows\release.yml', '.github\scripts\build_release.py')) {
            if (-not (Test-Path -LiteralPath (Join-Path $root $f) -PathType Leaf)) { throw "Brak pliku $f" }
        }
        $sounds = @(Get-ChildItem -LiteralPath (Join-Path $root 'sounds') -Recurse -File -Filter '*.ogg')
        if ($sounds.Count -lt 1) { throw 'Brak OGG. Rozpakuj cala paczke, nie sam skrypt.' }
        $manifestText = [IO.File]::ReadAllText((Join-Path $root 'pack.toml'))
        if (-not $manifestText.Contains('origin = "https://github.com/Patras93/soulbound-soundpack/releases/latest/download/Soulbound-Soundpack.zip"')) {
            throw 'Nieprawidlowy adres updatera w pack.toml.'
        }
        if (-not $manifestText.Contains('version = "1.5.7"')) { throw 'Nieprawidlowa wersja w pack.toml.' }

        & gh auth status *> $null
        if ($LASTEXITCODE -ne 0) {
            Write-Host 'Zaloguj sie na GitHub w terminalu / przegladarce.'
            & gh auth login --hostname github.com --git-protocol https --web
            if ($LASTEXITCODE -ne 0) { throw 'Logowanie gh auth login nie powiodlo sie.' }
        }
        & gh auth setup-git
        if ($LASTEXITCODE -ne 0) { throw 'Nie udalo sie skonfigurowac dostepu GitHub w Git.' }

        Write-Host "Pobieram repozytorium: $repo"
        & git clone --quiet $repoUrl $dest
        if ($LASTEXITCODE -ne 0) { throw 'Blad git clone. Sprawdz polaczenie i uprawnienia do repozytorium.' }

        if (Test-Path -LiteralPath (Join-Path $dest 'sounds')) {
            Remove-Item -LiteralPath (Join-Path $dest 'sounds') -Recurse -Force
        }
        Copy-Item -LiteralPath (Join-Path $root 'sounds') -Destination (Join-Path $dest 'sounds') -Recurse -Force
        if (Test-Path -LiteralPath (Join-Path $dest '.github')) {
            Remove-Item -LiteralPath (Join-Path $dest '.github') -Recurse -Force
        }
        Copy-Item -LiteralPath (Join-Path $root '.github') -Destination (Join-Path $dest '.github') -Recurse -Force
        foreach ($f in @('pack.toml', 'soundpack.lua', 'README_PL.txt', 'CHANGELOG_PL.txt', 'README.md', 'PUBLIKUJ_NA_GITHUB.ps1', 'PUBLIKUJ_NA_GITHUB.cmd')) {
            Copy-Item -LiteralPath (Join-Path $root $f) -Destination (Join-Path $dest $f) -Force
        }

        & git -C $dest config user.name 'Patras93'
        & git -C $dest config user.email '93275458+Patras93@users.noreply.github.com'
        & git -C $dest add --all
        if ($LASTEXITCODE -ne 0) { throw 'Nie udalo sie dodac plikow do Git.' }
        & git -C $dest diff --cached --quiet
        if ($LASTEXITCODE -eq 1) {
            & git -C $dest commit --quiet -m 'Soulbound Soundpack v1.5.7 - GitHub updater i 66 OGG'
            if ($LASTEXITCODE -ne 0) { throw 'Blad git commit.' }
            & git -C $dest push --quiet origin HEAD:main
            if ($LASTEXITCODE -ne 0) { throw 'Blad git push. Pliki na GitHubie moga nie byc zaktualizowane.' }
            Write-Host 'SUKCES: Kod i wszystkie OGG wyslane do GitHub.'
        } elseif ($LASTEXITCODE -eq 0) {
            Write-Host 'Repozytorium juz ma te same pliki. Nie ma nic do wyslania.'
        } else { throw 'Blad porownania zmian Git.' }

        & gh release view $tag --repo $repo *> $null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "UWAGA: Wydanie $tag juz istnieje. Nie nadpisuje go automatycznie."
        } else {
            & gh release create $tag --repo $repo --target main --title "Soulbound Soundpack v1.5.7" --notes-file (Join-Path $dest 'CHANGELOG_PL.txt') --latest
            if ($LASTEXITCODE -ne 0) { throw 'Nie udalo sie opublikowac wydania GitHub.' }
            Write-Host "SUKCES: Wydanie $tag zostalo opublikowane."
        }
        Write-Host 'GitHub Actions doda Soulbound-Soundpack.zip do Assets wydania.'
        Write-Host "Sprawdz: https://github.com/$repo/actions"
        Write-Host "Wydanie: https://github.com/$repo/releases/tag/$tag"
    }
    catch {
        Write-Host ('BLAD: ' + $_.Exception.Message)
        Write-Host 'Nie usuwaj katalogu z rozpakowanym soundpackiem. Mozesz ponowic probe.'
    }
    finally {
        if (Test-Path -LiteralPath $dest) {
            Remove-Item -LiteralPath $dest -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}
