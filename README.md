# Soulbound Soundpack dla Generic MUD

Natywny soundpack Lua do Soulbound. Wersja **1.5.8** — 66 nagran OGG.

## Pobieranie i aktualizacje

Pobierz **Soulbound-Soundpack.zip** z [najnowszego wydania](https://github.com/Patras93/soulbound-soundpack/releases/latest), rozpakuj i w Generic MUD wybierz **Soundpacks → Set up a soundpack from a folder**.

Kolejne aktualizacje: **Soundpacks → Manage installed soundpacks → Update from source**, potem ponowne polaczenie. Generic MUD v0.24.0 nie informuje sam o aktualizacjach dowolnych repozytoriow.

## Automatyczna publikacja

W kolejnej wersji zwieksz `version` w `pack.toml` i wyslij kod na `main`. GitHub Actions sam utworzy GitHub Release i dolaczy plik **Soulbound-Soundpack.zip** z prawidlowym adresem aktualizacji (`origin`). Nie trzeba recznie tworzyc tagow ani publikowac Release. Workflow i status: [Actions](https://github.com/Patras93/soulbound-soundpack/actions).

Szczegoly: `README_PL.txt` i `CHANGELOG_PL.txt`.

Publikuj OGG tylko z odpowiednimi prawami do redystrybucji.
