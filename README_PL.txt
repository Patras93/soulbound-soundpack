SOULBOUND SOUNDPACK v1.5.8 — INSTALACJA I AUTOMATYCZNA PUBLIKACJA

Repozytorium: https://github.com/Patras93/soulbound-soundpack
Wydania: https://github.com/Patras93/soulbound-soundpack/releases

INSTALACJA DLA GRACZY
1. Pobierz plik Soulbound-Soundpack.zip z sekcji Assets najnowszego wydania.
2. Rozpakuj ZIP do folderu, w ktorym sa pack.toml, soundpack.lua i sounds.
3. W Generic MUD wybierz Soundpacks > Set up a soundpack from a folder.
4. Wskaz folder, aktywuj dla swiata Soulbound i polacz sie.
5. Przy kolejnej wersji wybierz Soundpacks > Manage installed soundpacks >
   Update from source i polacz sie ponownie. Nie trzeba ponownie instalowac.

PUBLIKACJA NOWYCH WERSJI — AUTOMATYCZNA
1. Zmien dzwieki lub skrypt i zwieksz numer wersji w pack.toml,
   np. z 1.5.8 na 1.5.9.
2. Wypchnij zmiany na galaz main repozytorium GitHub.
3. GitHub Actions sam zbuduje ZIP, sprawdzi pliki, utworzy Release
   v1.5.9 i dolaczy Soulbound-Soundpack.zip do Assets.
4. Nie trzeba recznie tworzyc tagu ani klikac Publish release.
5. Przebieg sprawdzisz na stronie:
   https://github.com/Patras93/soulbound-soundpack/actions

PUBLIKACJA Z WINDOWS
Jesli pracujesz na rozpakowanej paczce, mozesz uruchomic
PUBLIKUJ_NA_GITHUB.cmd. Skrypt wysyla pliki na main; GitHub Actions
automatycznie publikuje wydanie. Wymagane Git for Windows oraz
GitHub CLI i logowanie do wlasnego konta.

UWAGA
- Uprawnienia Actions: Settings > Actions > General >
  Workflow permissions > Read and write, jesli wymagane.
- Workflow nie nadpisuje istniejacego wydania o tym samym numerze.
- Generic MUD v0.24.0 nie powiadamia automatycznie o aktualizacjach
  tego niestandardowego repozytorium; gracze uzywaja Update from source.
- Nie publikuj nagran bez praw do redystrybucji ani hasel/tokenow.
- Zachowaj lokalna kopie przed testowaniem nowych zmian.
