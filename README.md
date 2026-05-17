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

# Wrapper macOS standalone per lo screensaver Matrix di Monroe Williams

Questo progetto NON sostituisce il motore grafico originale. Fornisce invece una piccola app Cocoa che funge da wrapper per incorporare e avviare il `Matrix.saver` originale come una normale applicazione o utility nella barra dei menu, senza doverlo installare dalle Impostazioni di Sistema come un classico screensaver.

Progetto originale: <https://github.com/monroewilliams/MatrixDownload>

Il repository dei sorgenti esclude intenzionalmente il `Matrix.saver` di Monroe Williams. Per compilare dal codice sorgente, è necessario scaricarlo dal progetto originale. I file DMG delle release possono invece includere il `.saver` originale, grazie all'autorizzazione concessa da Monroe.

## Motivazione

Le versioni recenti di macOS eseguono gli screensaver di terze parti tramite il processo di sistema `legacyScreenSaver`. Il progetto Matrix originale riporta alcune instabilità di macOS legate a questo processo, tra cui un consumo anomalo e crescente di CPU o memoria in seguito all'avvio di screensaver legacy o di terze parti. Il problema si verifica sulle versioni recenti di macOS e non sembra essere limitato esclusivamente all'architettura Apple Silicon.

Questo wrapper aggira il problema:

- caricando direttamente `Matrix.saver` da un normale processo applicativo;
- creando finestre a schermo intero e senza bordi su tutti i monitor;
- fornendo una piccola finestra dedicata per le impostazioni;
- rimanendo accessibile direttamente dalla barra dei menu di macOS.

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
- `Settings...`: apre il pannello indipendente delle impostazioni.
- `Quit`: chiude l'applicazione dalla barra dei menu.

Mentre Matrix è in esecuzione, è possibile interromperlo utilizzando la scorciatoia da tastiera configurata. Se non è stata impostata alcuna scorciatoia personalizzata, per impostazione predefinita l'animazione si chiuderà premendo qualsiasi tasto (inclusi i tasti modificatori). L'interruzione dell'animazione tramite mouse (movimento, clic o scorrimento) può essere abilitata o disabilitata dalle Impostazioni. L'app nella barra dei menu rimarrà comunque attiva.

## Impostazioni

Il wrapper salva le impostazioni nello stesso modulo `ScreenSaverDefaults` utilizzato dallo screensaver originale:

```text
org.indirect.screensaver.Matrix
```

Impostazioni supportate:

- **3D fade (Dissolvenza 3D)**: abilita o disabilita l'effetto di dissolvenza 3D originale.
- **Dimensione dei glifi (Glyph size)**: Piccolo (Small) / Medio (Medium) / Grande (Large).
- **Colori dei glifi**: colore primario, secondario e di evidenziazione (highlight) utilizzati nell'animazione.
- **Scorciatoia da tastiera per uscire**: permette di registrare una combinazione tasto modificatore + tasto (es. Command + M).
- **Ripristino scorciatoia (Reset shortcut)**: rimuove la scorciatoia personalizzata e ripristina l'uscita predefinita con qualsiasi tasto.
- **Uscita tramite mouse**: abilita o disabilita la chiusura dell'animazione tramite movimento del mouse, clic e scorrimento.

> **Nota:** Durante l'esecuzione, la scorciatoia configurata interrompe l'animazione a schermo intero. Se non ne è configurata una, la pressione di qualsiasi tasto chiuderà l'animazione di default. È possibile configurare in modo indipendente anche la reazione agli input del mouse.

## Compilazione dal Codice Sorgente

Requisiti:

- macOS
- Xcode Command Line Tools

Questo repository esclude volutamente il `Matrix.saver` originale dal controllo di versione. Scaricalo dal progetto originale di Monroe Williams e posiziona il bundle nella cartella principale (root) del repository:

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

Per una distribuzione pubblica senza avvisi da parte di Gatekeeper, è necessario firmare il pacchetto con un certificato Apple Developer ID e far autenticare (notarize) l'app e il file DMG.

## Riconoscimenti

Il motore grafico dello screensaver Matrix è stato creato da Monroe Williams:
<https://github.com/monroewilliams/MatrixDownload>

Questo repository fornisce esclusivamente un launcher standalone, un wrapper per la barra dei menu, la gestione delle impostazioni, l'icona dell'applicazione e la pacchettizzazione in formato DMG per lo screensaver originale.

Si prega di non contattare Monroe Williams per problemi relativi a questa app wrapper. I bug del wrapper, la pacchettizzazione, il comportamento della barra dei menu, l'interfaccia delle impostazioni e la distribuzione sono gestiti unicamente da questo progetto.

## Fork o Repository Separato?

Mantenere un repository separato è generalmente la scelta più chiara, poiché questo progetto funge da wrapper e pacchetto di distribuzione, non da modifica al codice sorgente originale dello screensaver.

Effettuare un fork di `monroewilliams/MatrixDownload` avrebbe senso solo qualora si volesse proporre questa modalità di pacchettizzazione al progetto originale (upstream) o per mantenere un collegamento visibile di fork direttamente su GitHub.

## Nota sulla Licenza / Ridistribuzione

Monroe Williams ha concesso il permesso di includere il `Matrix.saver` originale nel pacchetto di questo wrapper. Si prega di mantenere chiara l'attribuzione al progetto originale e di specificare che il supporto tecnico per questa app wrapper viene gestito in questa sede, e non dall'autore dello screensaver originale.
