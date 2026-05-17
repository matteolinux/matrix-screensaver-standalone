# Matrix Screensaver Standalone

Standalone macOS wrapper for Monroe Williams' Matrix screensaver.

This project does **not** replace the original Matrix rendering engine. It provides a small Cocoa wrapper app that can package and launch the original `Matrix.saver` as a normal macOS app/menu bar utility, without installing it through System Settings > Screen Saver.

Original project: <https://github.com/monroewilliams/MatrixDownload>

The source repository intentionally does not include Monroe Williams' `Matrix.saver`. To build from source, download it from the original project. Release DMGs may include the original `.saver` with Monroe's permission.

## Why

Recent macOS versions run third-party `.saver` plugins through Apple's `legacyScreenSaver` process. The original Matrix project documents Apple-side instability around that process, including cases where CPU or memory usage can grow after third-party or legacy screensavers are invoked. This has been observed on modern macOS with legacy/third-party screensavers and should not be described as certainly limited to Apple Silicon.

This wrapper avoids that path:

- it loads `Matrix.saver` directly from a normal app process;
- it creates fullscreen borderless windows on all screens;
- it exposes settings through its own small settings window;
- it can stay available from the macOS menu bar.

## Download And Install

Download the latest DMG from the GitHub Releases page:

```text
Matrix-Screensaver.dmg
```

Open the DMG and drag `Matrix Screensaver.app` to `Applications`.

Because local builds are ad-hoc signed unless you sign/notarize them yourself, macOS Gatekeeper may require right-click > Open the first time.

## Usage

Open `Matrix Screensaver.app`.

It appears as `M` in the menu bar.

Menu actions:

- `Start Matrix`: starts the fullscreen Matrix animation.
- `Settings...`: opens the standalone settings panel.
- `Quit`: exits the menu bar app.

When Matrix is running, the configured exit shortcut stops it. If no custom shortcut is configured, any key exits by default and modifier keys also exit. Mouse input exit, including movement, clicks, and scroll events, can be enabled or disabled in Settings. The menu bar app remains active.

## Settings

The wrapper writes settings to the same `ScreenSaverDefaults` module used by the original screensaver:

```text
org.indirect.screensaver.Matrix
```

Currently supported:

- `3D fade`: enables or disables the original 3D fade effect.
- Glyph size: Small / Medium / Large.
- Three glyph colors: primary, secondary, and highlight colors used by the animation.
- Exit keyboard shortcut: record a custom modifier + key combination, such as Command + M.
- Reset shortcut: removes the custom shortcut and restores the default any-key exit behavior.
- Mouse input exit: enables or disables exiting with mouse movement, clicks, and scroll events.

When Matrix is running, the configured shortcut exits the fullscreen animation. If no custom shortcut is configured, any key exits by default and modifier keys also exit. Mouse input exit, including movement, clicks, and scroll events, can be enabled or disabled.

## Build From Source

Requirements:

- macOS
- Xcode Command Line Tools

This repository keeps the original `Matrix.saver` out of source control. Download it from Monroe Williams' original project and place the bundle in the repository root:

```text
Matrix.saver
```

Original project:

<https://github.com/monroewilliams/MatrixDownload>

Releases:

<https://github.com/monroewilliams/MatrixDownload/releases>

Build the app:

```bash
scripts/build_app.sh
```

Create the DMG:

```bash
scripts/package_dmg.sh
```

The output is:

```text
dist/Matrix-Screensaver.dmg
```

## Signing And Notarization

The included build script signs ad-hoc:

```bash
codesign --force --sign - "Matrix Screensaver.app"
```

For public distribution without Gatekeeper friction, sign with an Apple Developer ID certificate and notarize the app/DMG.

## Attribution

The Matrix screensaver engine is by Monroe Williams:

<https://github.com/monroewilliams/MatrixDownload>

This repository provides a standalone launcher, menu bar wrapper, settings bridge, app icon, and DMG packaging around that original screensaver.

Please do not contact Monroe Williams for issues with this wrapper app. Wrapper bugs, packaging issues, menu bar behavior, settings UI, and distribution problems are maintained by this project.

## Fork Or Separate Repository?

A separate repository is usually clearer because this project is a wrapper/distribution package, not a change to the original screensaver source.

A fork of `monroewilliams/MatrixDownload` only makes sense if you want to propose this packaging approach upstream or keep a direct GitHub fork relationship.

## License / Redistribution Note

Monroe Williams has granted permission to include the original `Matrix.saver` in this wrapper package. Keep clear attribution to the original project and make it clear that support for the wrapper app is handled here, not by the original screensaver author.

---

# Matrix Screensaver Standalone - Italiano

Wrapper macOS standalone per lo screensaver Matrix di Monroe Williams.

Questo progetto **non** sostituisce il motore grafico originale. Fornisce una piccola app Cocoa wrapper che può incorporare e avviare il `Matrix.saver` originale come normale app/menu bar utility, senza installarlo dalle Impostazioni di Sistema come screensaver classico.

Progetto originale: <https://github.com/monroewilliams/MatrixDownload>

Il repository sorgente non include intenzionalmente il `Matrix.saver` di Monroe Williams. Per compilare da sorgente, scaricalo dal progetto originale. I DMG di release possono includere il `.saver` originale con il permesso di Monroe.

## Perché

Le versioni recenti di macOS eseguono gli screensaver di terze parti tramite il processo Apple `legacyScreenSaver`. Il progetto originale Matrix documenta instabilità lato Apple intorno a quel processo, inclusi casi in cui CPU o memoria possono crescere dopo l'invocazione di screensaver legacy o di terze parti. Il problema è stato osservato su macOS moderni con screensaver legacy/terze parti e non va descritto come certamente limitato ad Apple Silicon.

Questo wrapper evita quel percorso:

- carica direttamente `Matrix.saver` da un normale processo app;
- crea finestre fullscreen borderless su tutti gli schermi;
- espone i settings con una piccola finestra propria;
- può restare disponibile dalla barra dei menu di macOS.

## Download E Installazione

Scarica il DMG dalla pagina GitHub Releases:

```text
Matrix-Screensaver.dmg
```

Apri il DMG e trascina `Matrix Screensaver.app` su `Applications`.

Se la build non è firmata con Developer ID e notarizzata, macOS Gatekeeper potrebbe richiedere tasto destro > Apri al primo avvio.

## Uso

Apri `Matrix Screensaver.app`.

Compare una `M` nella barra dei menu.

Azioni disponibili:

- `Start Matrix`: avvia l'animazione fullscreen.
- `Settings...`: apre il pannello settings standalone.
- `Quit`: chiude la menu bar app.

Quando Matrix è in esecuzione, la shortcut di uscita configurata lo ferma. Se non è configurata una shortcut custom, qualsiasi tasto esce di default e anche i tasti modificatori escono. L'uscita tramite mouse, inclusi movimento, click e scroll, si abilita o disabilita nei Settings. La app nella barra dei menu resta attiva.

## Settings

Il wrapper scrive i settings nello stesso modulo `ScreenSaverDefaults` usato dallo screensaver originale:

```text
org.indirect.screensaver.Matrix
```

Supportati:

- `3D fade`: abilita o disabilita l'effetto 3D fade originale.
- Dimensione glyph: Small / Medium / Large.
- Tre colori dei glyph: colore primario, secondario e highlight usati dall'animazione.
- Shortcut da tastiera per uscire: registra una combinazione modificatore + tasto, per esempio Command + M.
- Reset shortcut: rimuove la shortcut custom e ripristina l'uscita di default con qualsiasi tasto.
- Uscita tramite mouse: abilita o disabilita uscita con movimento, click e scroll.

Quando Matrix è in esecuzione, la shortcut configurata chiude l'animazione fullscreen. Se non è configurata una shortcut custom, qualsiasi tasto esce di default e anche i tasti modificatori escono. L'uscita tramite mouse, inclusi movimento, click e scroll, si abilita o disabilita.

## Compilazione Da Sorgente

Requisiti:

- macOS
- Xcode Command Line Tools

Questo repository tiene il `Matrix.saver` originale fuori dal controllo sorgente. Scaricalo dal progetto originale di Monroe Williams e metti il bundle nella root del repository:

```text
Matrix.saver
```

Progetto originale:

<https://github.com/monroewilliams/MatrixDownload>

Release:

<https://github.com/monroewilliams/MatrixDownload/releases>

Compila la app:

```bash
scripts/build_app.sh
```

Crea il DMG:

```bash
scripts/package_dmg.sh
```

Output:

```text
dist/Matrix-Screensaver.dmg
```

## Firma E Notarizzazione

Lo script incluso firma ad-hoc:

```bash
codesign --force --sign - "Matrix Screensaver.app"
```

Per una distribuzione pubblica senza avvisi Gatekeeper, firma con certificato Apple Developer ID e notarizza app/DMG.

## Attribuzione

Il motore dello screensaver Matrix è di Monroe Williams:

<https://github.com/monroewilliams/MatrixDownload>

Questo repository fornisce launcher standalone, wrapper menu bar, gestione settings, icona app e packaging DMG intorno allo screensaver originale.

Non contattare Monroe Williams per problemi con questa app wrapper. Bug del wrapper, packaging, comportamento menu bar, UI settings e distribuzione sono mantenuti da questo progetto.

## Fork O Repository Separato?

Un repository separato è in genere più chiaro, perché questo progetto è un wrapper/pacchetto distributivo, non una modifica al sorgente originale dello screensaver.

Un fork di `monroewilliams/MatrixDownload` ha senso solo se vuoi proporre questa modalità di packaging upstream o mantenere una relazione diretta di fork su GitHub.

## Nota Licenza / Redistribuzione

Monroe Williams ha dato permesso di includere il `Matrix.saver` originale nel pacchetto di questo wrapper. Mantieni l'attribuzione chiara al progetto originale e chiarisci che il supporto per la app wrapper viene gestito qui, non dall'autore dello screensaver originale.
