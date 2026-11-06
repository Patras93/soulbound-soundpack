SOULBOUND SOUNDPACK v1.5.9 — INSTRUKCJA

GitHub: https://github.com/Patras93/soulbound-soundpack
Wydania: https://github.com/Patras93/soulbound-soundpack/releases

INSTALACJA
1. Pobierz Soulbound-Soundpack.zip z ostatniego wydania (Assets).
2. Rozpakuj ZIP. Otworz Generic MUD > Soundpacks > Set up a soundpack
   from a folder i wskaz folder z pack.toml i soundpack.lua.
3. Wlacz pakiet dla swiata Soulbound i polacz sie ponownie.
4. Jesli masz juz v1.5.8, zamiast instalowac od nowa wybierz
   Soundpacks > Manage installed soundpacks > Update from source.
   Polacz sie ponownie, aby zaladowac nowy skrypt.

KOMENDY
sbs status          — stan i poziomy glosnosci
sbs music status    — stan muzyki
sbs music off       — wylacza tylko muzyke mobow
sbs music on        — wlacza muzyke mobow
sbs musicvol 25     — muzyka 25% glosnosci efektow (0-100)
sbs musicstop       — zatrzymuje aktualna muzyke walki
sbs vol 70          — glosnosc efektow 70% (0-100)
sbs test ep         — test nagrody EP
sbs test gold       — test nagrody monetarnej
sbs testmob awful   — podglad muzyki moba (odtwarza raz)
sbs testplayer awful — podglad glosu kondycji gracza
sbs teststop        — zatrzymuje podglady
sbs diag            — licznik zdarzen, bledow i ostatnich danych
sbs updater         — informacja o aktualizacji

Stan moba ma poziomy: excellent, scratches, small wounds,
quite a few, pretty hurt, big nasty, awful, dying. Dzwiek
mob/died.ogg: sbs testmob died. Gracz nie ma dying ani died.

PUBLIKACJA NA GITHUB
- Wprowadz zmiany w repozytorium i zwieksz version w pack.toml.
- Wyslij commit na main (np. przez PUBLIKUJ_NA_GITHUB.cmd).
- GitHub Actions automatycznie przetestuje Lua, sprawdzi pliki,
  utworzy Release z nowym tagiem i dolaczy Soulbound-Soundpack.zip.
- Nie tworz recznie taga i nie klikaj Publish release.
- W razie odmowy zapisu sprawdz Settings > Actions > General >
  Workflow permissions — Read and write.

UWAGA
- Nowe OGG publikuj tylko majac prawa do ich redystrybucji.
- Prawdziwy crossfade jest niedostepny przez natywne Lua 0.24.0.
- Auto-publikacja po commicie nie oznacza automatycznej aktualizacji
  na komputerach graczy. Update from source wymaga wybrania w menu.
