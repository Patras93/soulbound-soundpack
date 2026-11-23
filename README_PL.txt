SOULBOUND SOUNDPACK v1.6.10 — INSTRUKCJA (PL)

Repozytorium: https://github.com/Patras93/soulbound-soundpack
Wydania: https://github.com/Patras93/soulbound-soundpack/releases
Gra: Soulbound v116.00.68 (zgodnosc ze starszymi wersjami)
Klient: Generic MUD v0.24.0+. Zestaw: 87 OGG.

OVER CAP — START EVENTU
- events/double caps.ogg gra na rzeczywisty komunikat
  "EVENT OVER CAP START" nadawany co godzine o XX:30.
- Koniec o XX:45 nie odtwarza startowego dzwieku.
- Dzwiek nie gra po sprawdzeniu statusu, pozostalego czasu
  ani po samym zalogowaniu do gry.
- Stare serwery ze znacznikiem SOUND_EVENT OVER_CAP_START
  nadal sa obslugiwane, bez podwojnego efektu tekst + marker.
- events/overcap.ogg to OSOBNY dzwiek ponadlimitowej nagrody EXP.
  Od v116.64 gra ma EXP bez limitu, dlatego nie emituje juz
  odpowiedniego zdarzenia nagrody. Nie jest to blad pliku OGG.
- Serwer nadal oglasza wydarzenie mimo usuniecia limitow CAP.
  Ten soundpack nie zmienia zasad EXP ani nie przyznaje premii.

KOMENDY TESTOWE
sbs test doublecaps  — odsluch startu Over Cap
sbs test overcap     — odsluch oddzielnego efektu ponad limit
sbs status           — wersja soundpacka
sbs diag             — stan i diagnostyka

AKTUALIZACJA
Generic MUD > Soundpacks > Manage installed soundpacks >
Update from source. Nastepnie polacz sie ponownie.

Zachowano wszystkie dotychczasowe nagrania i zdarzenia.
Automatyczny Release i ZIP tworzy GitHub Actions. Bez CMD/BAT.

Udostepniaj nagrania tylko z prawem do ich redystrybucji.
