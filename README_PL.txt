SOULBOUND SOUNDPACK v1.6.1 — INSTRUKCJA (PL)

Projekt: https://github.com/Patras93/soulbound-soundpack
Wydania: https://github.com/Patras93/soulbound-soundpack/releases
GRA: Soulbound v107.00.0, Generic MUD v0.24.0+.

INSTALACJA DLA GRACZY
1. Ze strony GitHub Releases pobierz Soulbound-Soundpack.zip.
2. Wypakuj folder z pack.toml, soundpack.lua i sounds.
3. W Generic MUD: Soundpacks > Set up a soundpack from a folder.
4. Wlacz soundpack dla swiata Soulbound i polacz sie ponownie.
5. Kolejna wersja: Soundpacks > Manage installed soundpacks >
   Update from source, nastepnie ponowne polaczenie z gra.

DODANE EFEKTY
- announce.ogg — wydarzenie swiata / boss / event administracji.
- steps/1..10.ogg — kroki po miescie.
- steps/caves/1..4.ogg — chodzenie po jaskiniach, kryptach, podziemiach.
- soul level.ogg — awans Soul Level Broni Duszy.
- Dzwiek wydarzenia x2 EXP nie zostal zmieniony.

KOMENDY KROKOW
sbs steps on       — wlacz kroki miejskie
sbs steps off      — wylacz kroki miejskie
sbs steps status   — stan i licznik
sbs steps test     — podglad kolejnego kroku
sbs caves on       — wlacz kroki podziemne
sbs caves off      — wylacz kroki podziemne
sbs caves status   — stan i licznik
sbs caves test     — podglad kolejnego kroku
sbs test announce  — podglad dzwieku wydarzenia
sbs test soullevel — podglad dzwieku awansu Duszy
sbs music status  — stan muzyki mobow
sbs musicvol 25   — glosnosc muzyki (0-100)
sbs diag           — diagnostyka
sbs updater        — instrukcja aktualizacji

PUBLIKACJA NOWEGO WYDANIA PRZEZ GITHUB
1. Rozpakuj ZRODLOWY ZIP do katalogu z pack.toml i PUBLIKUJ_NA_GITHUB.cmd.
2. Uruchom PUBLIKUJ_NA_GITHUB.cmd. Musisz miec Git i GitHub CLI,
   a konto GH musi miec uprawnienia do repozytorium Patras93.
3. Skrypt wgra wszystkie OGG, kod i testy na galaz main.
4. GitHub Actions wykona testy, utworzy Release v1.6.1 i doda
   Soulbound-Soundpack.zip automatycznie. W serwisie sprawdz Actions.
5. Nie tworz recznie tagu ani Release; nie wgrywaj pojedynczych OGG
   przez przegladarke.

UWAGA: automatyczne PUBLIKOWANIE na GitHub po git push nie jest
równoznaczne z automatycznym POBIERANIEM na komputerach graczy;
Generic MUD ma opcje Update from source uruchamiana z menu.
Przy publicznym udostepnianiu nagran nalezy miec prawa do redystrybucji.
