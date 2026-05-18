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

When Matrix is running, the configured exit shortcut stops it. If no custom shortcut is configured, any key exits by default and modifier keys also exit. Mouse input exit, including movement, clicks, and scroll events, can be enabled or disabled in Settings. Touch ID or Mac password authentication can also be required before an exit trigger is accepted. The menu bar app remains active.

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
- Touch ID or Mac password exit: requires macOS user authentication before an exit trigger closes Matrix.

When Matrix is running, the configured shortcut exits the fullscreen animation. If no custom shortcut is configured, any key exits by default and modifier keys also exit. Mouse input exit, including movement, clicks, and scroll events, can be enabled or disabled. When authentication exit is enabled, the same exit triggers first show the macOS authentication prompt. This is only an app-level exit gate; use the macOS lock screen for real access control.

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

Wrapper standalone per macOS dello screensaver Matrix di Monroe Williams.

Questo progetto **non** sostituisce il motore grafico originale. Fornisce una piccola app Cocoa che incorpora e avvia il `Matrix.saver` originale come normale app con utilità nella barra dei menu, senza installarlo dalle Impostazioni di Sistema come salvaschermo classico.

Progetto originale: <https://github.com/monroewilliams/MatrixDownload>

Il repository sorgente non include intenzionalmente il `Matrix.saver` di Monroe Williams. Per compilare da sorgente, scaricalo dal progetto originale. I DMG pubblicati possono includere il `.saver` originale con il permesso di Monroe.

## Motivazione

Le versioni recenti di macOS eseguono gli screensaver di terze parti tramite il processo Apple `legacyScreenSaver`. Il progetto originale Matrix documenta instabilità lato Apple intorno a quel processo, inclusi casi in cui CPU o memoria possono crescere dopo l'avvio di salvaschermi legacy o di terze parti. Il problema è stato osservato su versioni moderne di macOS con salvaschermi legacy/di terze parti e non va descritto come certamente limitato ad Apple Silicon.

Questo wrapper aggira il problema:

- carica direttamente `Matrix.saver` da un normale processo dell'app;
- crea finestre a schermo intero senza bordi su tutti gli schermi;
- espone le impostazioni con una piccola finestra propria;
- può restare disponibile dalla barra dei menu di macOS.

## Download e Installazione

Scarica il file DMG dalla pagina delle Release su GitHub:

```text
Matrix-Screensaver.dmg
```

Apri il DMG e trascina `Matrix Screensaver.app` nella cartella `Applicazioni`.

Poiché la build potrebbe non essere firmata con un Developer ID e non autenticata (notarized) da Apple, al primo avvio macOS Gatekeeper potrebbe bloccare l'app. Per aprirla, fai clic destro sull'applicazione e seleziona **Apri**.

## Utilizzo

Apri `Matrix Screensaver.app`.

Comparirà una `M` nella barra dei menu di macOS.

Azioni disponibili:

- `Start Matrix`: avvia l'animazione a schermo intero.
- `Settings...`: apre il pannello delle impostazioni standalone.
- `Quit`: chiude l'app nella barra dei menu.

Quando Matrix è in esecuzione, la scorciatoia di uscita configurata lo ferma. Se non è configurata una scorciatoia personalizzata, qualsiasi tasto esce per impostazione predefinita, inclusi i tasti modificatori. L'uscita tramite mouse, inclusi movimento, clic e scorrimento, si può abilitare o disabilitare nelle impostazioni. Si può anche richiedere l'autenticazione con Touch ID o password del Mac prima di accettare un comando di uscita. L'app nella barra dei menu resta attiva.

## Impostazioni

Il wrapper scrive le impostazioni nello stesso modulo `ScreenSaverDefaults` usato dallo screensaver originale:

```text
org.indirect.screensaver.Matrix
```

Impostazioni supportate:

- `3D fade`: abilita o disabilita l'effetto 3D fade originale.
- Dimensione dei glifi: Small / Medium / Large.
- Tre colori dei glifi: colore primario, secondario e di evidenziazione usati dall'animazione.
- Scorciatoia da tastiera per uscire: registra una combinazione modificatore + tasto, per esempio Command + M.
- Reset scorciatoia: rimuove la scorciatoia personalizzata e ripristina l'uscita predefinita con qualsiasi tasto.
- Uscita tramite mouse: abilita o disabilita l'uscita con movimento, clic e scorrimento.
- Uscita con Touch ID o password del Mac: richiede l'autenticazione utente macOS prima di chiudere Matrix.

Quando Matrix è in esecuzione, la scorciatoia configurata chiude l'animazione a schermo intero. Se non è configurata una scorciatoia personalizzata, qualsiasi tasto esce per impostazione predefinita, inclusi i tasti modificatori. L'uscita tramite mouse, inclusi movimento, clic e scorrimento, si può abilitare o disabilitare. Quando l'uscita con autenticazione è abilitata, gli stessi comandi mostrano prima il prompt di autenticazione macOS. Questa è solo una protezione a livello di app; per un vero controllo degli accessi usa il blocco schermo di macOS.

## Compilazione dal Codice Sorgente

Requisiti:

- macOS
- Xcode Command Line Tools

Questo repository tiene il `Matrix.saver` originale fuori dal controllo sorgente. Scaricalo dal progetto originale di Monroe Williams e metti il bundle nella radice del repository:

```text
Matrix.saver
```

Progetto originale:
<https://github.com/monroewilliams/MatrixDownload>

Release:
<https://github.com/monroewilliams/MatrixDownload/releases>

Compila l'app:

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

## Firma e Autenticazione (Notarization)

Lo script incluso esegue una firma ad-hoc:

```bash
codesign --force --sign - "Matrix Screensaver.app"
```

Per una distribuzione pubblica senza avvisi Gatekeeper, firma con un certificato Apple Developer ID e notarizza app e DMG.

## Riconoscimenti

Il motore grafico dello screensaver Matrix è stato creato da Monroe Williams:
<https://github.com/monroewilliams/MatrixDownload>

Questo repository fornisce launcher standalone, wrapper per la barra dei menu, gestione delle impostazioni, icona dell'app e packaging DMG intorno allo screensaver originale.

Non contattare Monroe Williams per problemi con questa app wrapper. Bug del wrapper, packaging, comportamento nella barra dei menu, interfaccia delle impostazioni e distribuzione sono gestiti da questo progetto.

## Fork o Repository Separato?

Mantenere un repository separato è generalmente la scelta più chiara, poiché questo progetto funge da wrapper e pacchetto di distribuzione, non da modifica al codice sorgente originale dello screensaver.

Effettuare un fork di `monroewilliams/MatrixDownload` avrebbe senso solo qualora si volesse proporre questa modalità di pacchettizzazione al progetto originale (upstream) o per mantenere un collegamento visibile di fork direttamente su GitHub.

## Nota sulla Licenza / Ridistribuzione

Monroe Williams ha dato il permesso di includere il `Matrix.saver` originale nel pacchetto di questo wrapper. Mantieni chiara l'attribuzione al progetto originale e specifica che il supporto per l'app wrapper viene gestito qui, non dall'autore dello screensaver originale.
