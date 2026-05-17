import Cocoa
import ScreenSaver

private let exitShortcutKeyCodeKey = "StandaloneExitShortcutKeyCode"
private let exitShortcutModifierFlagsKey = "StandaloneExitShortcutModifierFlags"
private let exitOnMouseMovementKey = "StandaloneExitOnMouseMovement"

fileprivate struct ExitShortcut {
    let keyCode: UInt16
    let modifierFlags: NSEvent.ModifierFlags

    static let relevantModifierFlags: NSEvent.ModifierFlags = [.command, .option, .control, .shift]

    var displayString: String {
        let symbols: [(NSEvent.ModifierFlags, String)] = [
            (.control, "Control"),
            (.option, "Option"),
            (.shift, "Shift"),
            (.command, "Command")
        ]
        let modifiers = symbols
            .filter { modifierFlags.contains($0.0) }
            .map { $0.1 }

        return (modifiers + [Self.keyName(for: keyCode)]).joined(separator: " + ")
    }

    func matches(_ event: NSEvent) -> Bool {
        event.keyCode == keyCode &&
            event.modifierFlags.intersection(Self.relevantModifierFlags) == modifierFlags
    }

    static func from(defaults: UserDefaults?) -> ExitShortcut? {
        guard
            let defaults,
            defaults.object(forKey: exitShortcutKeyCodeKey) != nil
        else {
            return nil
        }

        let rawModifiers = UInt(defaults.integer(forKey: exitShortcutModifierFlagsKey))
        return ExitShortcut(
            keyCode: UInt16(defaults.integer(forKey: exitShortcutKeyCodeKey)),
            modifierFlags: NSEvent.ModifierFlags(rawValue: rawModifiers)
                .intersection(relevantModifierFlags)
        )
    }

    static func keyName(for keyCode: UInt16) -> String {
        let commonKeys: [UInt16: String] = [
            0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X",
            8: "C", 9: "V", 11: "B", 12: "Q", 13: "W", 14: "E", 15: "R",
            16: "Y", 17: "T", 18: "1", 19: "2", 20: "3", 21: "4", 22: "6",
            23: "5", 24: "=", 25: "9", 26: "7", 27: "-", 28: "8", 29: "0",
            30: "]", 31: "O", 32: "U", 33: "[", 34: "I", 35: "P", 37: "L",
            38: "J", 39: "'", 40: "K", 41: ";", 42: "\\", 43: ",", 44: "/",
            45: "N", 46: "M", 47: ".", 50: "`"
        ]

        if let keyName = commonKeys[keyCode] {
            return keyName
        }

        switch keyCode {
        case 36: return "Return"
        case 48: return "Tab"
        case 49: return "Space"
        case 51: return "Delete"
        case 53: return "Escape"
        case 71: return "Clear"
        case 76: return "Enter"
        case 96: return "F5"
        case 97: return "F6"
        case 98: return "F7"
        case 99: return "F3"
        case 100: return "F8"
        case 101: return "F9"
        case 103: return "F11"
        case 109: return "F10"
        case 111: return "F12"
        case 118: return "F4"
        case 120: return "F2"
        case 122: return "F1"
        case 123: return "Left Arrow"
        case 124: return "Right Arrow"
        case 125: return "Down Arrow"
        case 126: return "Up Arrow"
        default:
            return "Key \(keyCode)"
        }
    }
}

fileprivate final class ShortcutRecorderButton: NSButton {
    var shortcut: ExitShortcut? {
        didSet {
            isRecording = false
            updateTitle()
        }
    }

    private var isRecording = false

    override var acceptsFirstResponder: Bool { true }
    override var canBecomeKeyView: Bool { true }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override func performClick(_ sender: Any?) {
        startRecording()
    }

    override func keyDown(with event: NSEvent) {
        guard isRecording else {
            super.keyDown(with: event)
            return
        }

        if event.keyCode == 53 {
            isRecording = false
            updateTitle()
            return
        }

        let modifiers = event.modifierFlags.intersection(ExitShortcut.relevantModifierFlags)
        guard !modifiers.isEmpty else {
            NSSound.beep()
            title = "Use modifier + key"
            return
        }

        shortcut = ExitShortcut(
            keyCode: event.keyCode,
            modifierFlags: modifiers
        )
    }

    private func setup() {
        bezelStyle = .rounded
        target = self
        action = #selector(recordShortcut(_:))
        updateTitle()
    }

    @objc private func recordShortcut(_ sender: Any?) {
        startRecording()
    }

    private func startRecording() {
        isRecording = true
        title = "Press shortcut..."
        window?.makeFirstResponder(self)
    }

    private func updateTitle() {
        title = shortcut?.displayString ?? "Any Key"
    }
}

final class SaverWindow: NSWindow {
    var keyboardExitHandler: ((NSEvent) -> Bool)?
    var modifierExitHandler: ((NSEvent) -> Bool)?
    var mouseExitHandler: (() -> Void)?
    var mouseMovementExitHandler: (() -> Void)?

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    override func keyDown(with event: NSEvent) {
        if keyboardExitHandler?(event) == true {
            return
        }

        super.keyDown(with: event)
    }

    override func flagsChanged(with event: NSEvent) {
        if modifierExitHandler?(event) == true {
            return
        }

        super.flagsChanged(with: event)
    }

    override func mouseMoved(with event: NSEvent) {
        mouseMovementExitHandler?()
    }

    override func mouseDown(with event: NSEvent) {
        mouseExitHandler?()
    }

    override func rightMouseDown(with event: NSEvent) {
        mouseExitHandler?()
    }

    override func otherMouseDown(with event: NSEvent) {
        mouseExitHandler?()
    }

    override func scrollWheel(with event: NSEvent) {
        mouseExitHandler?()
    }

    override func cancelOperation(_ sender: Any?) {
        guard
            let event = NSApp.currentEvent,
            keyboardExitHandler?(event) == true
        else {
            return
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private var windows: [SaverWindow] = []
    private var saverViews: [ScreenSaverView] = []
    private var eventMonitor: Any?
    private var statusItem: NSStatusItem?
    private var saverClass: ScreenSaverView.Type?
    private var menuBarMode = false
    private var allowQuit = false
    private var childProcesses: [Process] = []
    private var settingsView: ScreenSaverView?
    private var settingsWindow: NSWindow?
    private var fadeCheckbox: NSButton?
    private var cellSizePopup: NSPopUpButton?
    private var shortcutRecorder: ShortcutRecorderButton?
    private var mouseMovementCheckbox: NSButton?
    private var colorWells: [NSColorWell] = []
    private var exitOnMouseMovement = true
    private var mouseMovementExitArmedAt = Date.distantPast

    func applicationDidFinishLaunching(_ notification: Notification) {
        let launchOptions = Self.launchOptions()
        menuBarMode = launchOptions.menuBar
        let saverURL = launchOptions.saverURL
        guard let bundle = Bundle(url: saverURL) else {
            fail("Cannot open bundle at \(saverURL.path)")
            return
        }

        do {
            try bundle.loadAndReturnError()
        } catch {
            fail("Cannot load \(saverURL.path): \(error.localizedDescription)")
            return
        }

        guard let saverClass = bundle.principalClass as? ScreenSaverView.Type else {
            fail("Bundle principal class is not a ScreenSaverView")
            return
        }
        self.saverClass = saverClass

        if launchOptions.showSettings {
            activateForUserInterface()
            showSettings()
            return
        }

        if launchOptions.menuBar {
            showMenuBarItem()
            return
        }

        startScreensaver()
    }

    func applicationWillTerminate(_ notification: Notification) {
        childProcesses.forEach { process in
            if process.isRunning {
                process.terminate()
            }
        }
        cleanupScreensaver()
        NSCursor.unhide()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        !menuBarMode
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        if menuBarMode && !allowQuit {
            ensureMenuBarItem()
            return .terminateCancel
        }

        return .terminateNow
    }

    func windowWillClose(_ notification: Notification) {
        if settingsWindow === notification.object as? NSWindow {
            settingsWindow = nil
            if menuBarMode {
                ensureMenuBarItem()
            } else {
                NSApp.terminate(nil)
            }
        }
    }

    @objc private func startFromMenu(_ sender: Any?) {
        launchHelper(showSettings: false)
    }

    @objc private func openSettingsFromMenu(_ sender: Any?) {
        launchHelper(showSettings: true)
    }

    @objc private func quitFromMenu(_ sender: Any?) {
        allowQuit = true
        NSApp.terminate(nil)
    }

    private func showMenuBarItem() {
        ensureMenuBarItem()
    }

    private func ensureMenuBarItem() {
        if statusItem != nil {
            return
        }

        if !menuBarMode {
            NSApp.setActivationPolicy(.accessory)
        }

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.title = "M"
        item.button?.toolTip = "Matrix Screensaver"

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Start Matrix", action: #selector(startFromMenu(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(openSettingsFromMenu(_:)), keyEquivalent: ","))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitFromMenu(_:)), keyEquivalent: "q"))

        for menuItem in menu.items {
            menuItem.target = self
        }

        item.menu = menu
        statusItem = item
    }

    private func launchHelper(showSettings: Bool) {
        guard let executableURL = Bundle.main.executableURL else {
            return
        }

        let process = Process()
        process.executableURL = executableURL

        var arguments: [String] = []
        if showSettings {
            arguments.append("--settings")
        }

        if let saverURL = Self.availableSaverURL() {
            arguments.append(saverURL.path)
        }

        process.arguments = arguments
        process.terminationHandler = { [weak self, weak process] _ in
            DispatchQueue.main.async {
                guard let self, let process else {
                    return
                }

                self.childProcesses.removeAll { $0 === process }
                self.ensureMenuBarItem()
            }
        }

        do {
            try process.run()
            childProcesses.append(process)
        } catch {
            fputs("Matrix launcher error: Cannot launch helper: \(error.localizedDescription)\n", stderr)
        }
    }

    private func activateForUserInterface() {
        if !menuBarMode {
            NSApp.setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        NSRunningApplication.current.activate()
    }

    private func startScreensaver() {
        guard windows.isEmpty else {
            return
        }

        guard let saverClass else {
            fail("Screen saver class is not loaded")
            return
        }

        activateForUserInterface()
        NSCursor.hide()

        let exitShortcut = Self.savedExitShortcut()
        exitOnMouseMovement = Self.savedExitOnMouseMovement()
        mouseMovementExitArmedAt = Date().addingTimeInterval(0.35)

        eventMonitor = NSEvent.addLocalMonitorForEvents(
            matching: [.keyDown, .flagsChanged, .leftMouseDown, .rightMouseDown, .otherMouseDown, .scrollWheel, .mouseMoved]
        ) { event in
            switch event.type {
            case .keyDown where Self.shouldExitForKey(event, shortcut: exitShortcut):
                self.stopScreensaver()
                return nil
            case .flagsChanged where Self.shouldExitForModifier(event, shortcut: exitShortcut):
                self.stopScreensaver()
                return nil
            case .leftMouseDown, .rightMouseDown, .otherMouseDown, .scrollWheel:
                guard self.shouldExitForMouseInput() else {
                    return event
                }

                self.stopScreensaver()
                return nil
            case .mouseMoved where self.shouldExitForMouseMovement():
                self.stopScreensaver()
                return nil
            default:
                return event
            }
        }

        let keyboardExitHandler: (NSEvent) -> Bool = { [weak self] event in
            guard Self.shouldExitForKey(event, shortcut: exitShortcut) else {
                return false
            }

            self?.stopScreensaver()
            return true
        }

        let modifierExitHandler: (NSEvent) -> Bool = { [weak self] event in
            guard Self.shouldExitForModifier(event, shortcut: exitShortcut) else {
                return false
            }

            self?.stopScreensaver()
            return true
        }

        let mouseExitHandler: () -> Void = { [weak self] in
            guard self?.shouldExitForMouseInput() == true else {
                return
            }

            self?.stopScreensaver()
        }

        let mouseMovementExitHandler: () -> Void = { [weak self] in
            guard self?.shouldExitForMouseMovement() == true else {
                return
            }

            self?.stopScreensaver()
        }

        for screen in NSScreen.screens {
            let frame = screen.frame
            let window = SaverWindow(
                contentRect: frame,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false,
                screen: screen
            )
            window.level = .screenSaver
            window.backgroundColor = .black
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
            window.acceptsMouseMovedEvents = true
            window.keyboardExitHandler = keyboardExitHandler
            window.modifierExitHandler = modifierExitHandler
            window.mouseExitHandler = mouseExitHandler
            window.mouseMovementExitHandler = mouseMovementExitHandler

            guard let saverView = saverClass.init(frame: NSRect(origin: .zero, size: frame.size), isPreview: false) else {
                fail("Cannot instantiate ScreenSaverView")
                return
            }

            applySavedDefaults(to: saverView)
            saverView.autoresizingMask = [.width, .height]
            window.contentView = saverView
            windows.append(window)
            saverViews.append(saverView)
            window.makeKeyAndOrderFront(nil)
            saverView.startAnimation()
            refreshSimulationPreferences(for: saverView)
        }
    }

    private func stopScreensaver() {
        cleanupScreensaver()
        NSCursor.unhide()

        if menuBarMode {
            ensureMenuBarItem()
            NSRunningApplication.current.activate(options: [])
        } else {
            NSApp.terminate(nil)
        }
    }

    private func cleanupScreensaver() {
        saverViews.forEach { $0.stopAnimation() }
        windows.forEach { window in
            window.keyboardExitHandler = nil
            window.modifierExitHandler = nil
            window.mouseExitHandler = nil
            window.mouseMovementExitHandler = nil
            window.close()
        }
        saverViews.removeAll()
        windows.removeAll()

        if let eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
            self.eventMonitor = nil
        }
    }

    private func showSettings() {
        let settingsWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 328),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )

        settingsWindow.contentView = makeSettingsView()
        self.settingsWindow = settingsWindow
        settingsWindow.delegate = self
        settingsWindow.title = "Matrix Screensaver Settings"
        settingsWindow.level = .floating
        settingsWindow.center()
        settingsWindow.makeKeyAndOrderFront(nil)
    }

    private func wireSettingsButtons(in view: NSView?) {
        guard let view else {
            return
        }

        if let button = view as? NSButton {
            switch button.title {
            case "OK":
                button.target = self
                button.action = #selector(saveSettings(_:))
            case "Cancel":
                button.target = self
                button.action = #selector(cancelSettings(_:))
            default:
                break
            }
        }

        for subview in view.subviews {
            wireSettingsButtons(in: subview)
        }
    }

    @objc private func saveSettings(_ sender: Any?) {
        saveCustomSettings()
        closeSettingsWindow()
    }

    @objc private func resetExitShortcut(_ sender: Any?) {
        shortcutRecorder?.shortcut = nil
    }

    @objc private func cancelSettings(_ sender: Any?) {
        performSettingsSelector("closeSheet_cancel:", sender: sender)
        closeSettingsWindow()
    }

    private func performSettingsSelector(_ selectorName: String, sender: Any?) {
        let selector = NSSelectorFromString(selectorName)
        guard let settingsView, settingsView.responds(to: selector) else {
            return
        }

        settingsView.perform(selector, with: sender)
        Self.matrixDefaults()?.synchronize()
    }

    private func makeSettingsView() -> NSView {
        let defaults = Self.matrixDefaults()
        defaults?.synchronize()

        let root = NSView(frame: NSRect(x: 0, y: 0, width: 420, height: 328))

        let fadeCheckbox = NSButton(checkboxWithTitle: "3D fade", target: nil, action: nil)
        fadeCheckbox.state = defaults?.bool(forKey: "3DFade") == true ? .on : .off
        fadeCheckbox.frame = NSRect(x: 24, y: 276, width: 160, height: 24)
        root.addSubview(fadeCheckbox)
        self.fadeCheckbox = fadeCheckbox

        let sizeLabel = NSTextField(labelWithString: "Glyph Size:")
        sizeLabel.frame = NSRect(x: 24, y: 234, width: 100, height: 20)
        root.addSubview(sizeLabel)

        let cellSizePopup = NSPopUpButton(frame: NSRect(x: 144, y: 228, width: 150, height: 28), pullsDown: false)
        cellSizePopup.addItem(withTitle: "Small")
        cellSizePopup.lastItem?.tag = 8
        cellSizePopup.addItem(withTitle: "Medium")
        cellSizePopup.lastItem?.tag = 16
        cellSizePopup.addItem(withTitle: "Large")
        cellSizePopup.lastItem?.tag = 32
        let savedCellSize = defaults?.integer(forKey: "CellSize") ?? 16
        cellSizePopup.selectItem(withTag: savedCellSize == 0 ? 16 : savedCellSize)
        root.addSubview(cellSizePopup)
        self.cellSizePopup = cellSizePopup

        let shortcutLabel = NSTextField(labelWithString: "Exit Shortcut:")
        shortcutLabel.frame = NSRect(x: 24, y: 190, width: 110, height: 20)
        root.addSubview(shortcutLabel)

        let shortcutRecorder = ShortcutRecorderButton(frame: NSRect(x: 144, y: 184, width: 180, height: 30))
        shortcutRecorder.shortcut = Self.savedExitShortcut()
        root.addSubview(shortcutRecorder)
        self.shortcutRecorder = shortcutRecorder

        let resetShortcutButton = NSButton(title: "Reset", target: self, action: #selector(resetExitShortcut(_:)))
        resetShortcutButton.frame = NSRect(x: 326, y: 184, width: 64, height: 30)
        root.addSubview(resetShortcutButton)

        let mouseMovementCheckbox = NSButton(checkboxWithTitle: "Exit on mouse movement", target: nil, action: nil)
        mouseMovementCheckbox.state = Self.savedExitOnMouseMovement(defaults: defaults) ? .on : .off
        mouseMovementCheckbox.frame = NSRect(x: 24, y: 146, width: 240, height: 24)
        root.addSubview(mouseMovementCheckbox)
        self.mouseMovementCheckbox = mouseMovementCheckbox

        let colorsLabel = NSTextField(labelWithString: "Colors:")
        colorsLabel.frame = NSRect(x: 24, y: 102, width: 100, height: 20)
        root.addSubview(colorsLabel)

        colorWells = []
        for index in 0..<3 {
            let well = NSColorWell(frame: NSRect(x: 144 + (index * 54), y: 94, width: 44, height: 28))
            well.color = Self.colorFromDefaults(defaults, key: "color\(index)") ?? Self.defaultColor(at: index)
            root.addSubview(well)
            colorWells.append(well)
        }

        let cancelButton = NSButton(title: "Cancel", target: self, action: #selector(cancelSettings(_:)))
        cancelButton.frame = NSRect(x: 232, y: 24, width: 78, height: 32)
        root.addSubview(cancelButton)

        let okButton = NSButton(title: "OK", target: self, action: #selector(saveSettings(_:)))
        okButton.frame = NSRect(x: 318, y: 24, width: 78, height: 32)
        okButton.keyEquivalent = "\r"
        root.addSubview(okButton)

        return root
    }

    private func saveCustomSettings() {
        guard let defaults = Self.matrixDefaults() else {
            return
        }

        defaults.set(fadeCheckbox?.state == .on, forKey: "3DFade")
        defaults.set(cellSizePopup?.selectedTag() ?? 16, forKey: "CellSize")
        defaults.set(mouseMovementCheckbox?.state != .off, forKey: exitOnMouseMovementKey)

        if let shortcut = shortcutRecorder?.shortcut {
            defaults.set(Int(shortcut.keyCode), forKey: exitShortcutKeyCodeKey)
            defaults.set(Int(shortcut.modifierFlags.rawValue), forKey: exitShortcutModifierFlagsKey)
        } else {
            defaults.removeObject(forKey: exitShortcutKeyCodeKey)
            defaults.removeObject(forKey: exitShortcutModifierFlagsKey)
        }

        for (index, well) in colorWells.enumerated() {
            defaults.set(Self.defaultsArray(from: well.color), forKey: "color\(index)")
        }

        defaults.synchronize()
        UserDefaults.standard.synchronize()
    }

    private func closeSettingsWindow() {
        settingsWindow?.delegate = nil
        settingsWindow?.close()
        settingsWindow = nil

        if menuBarMode {
            ensureMenuBarItem()
            NSRunningApplication.current.activate(options: [])
        } else {
            NSApp.terminate(nil)
        }
    }

    private func applySavedDefaults(to saverView: ScreenSaverView) {
        guard let defaults = Self.matrixDefaults() else {
            return
        }

        defaults.synchronize()

        let selector = NSSelectorFromString("setDefaults:")
        if saverView.responds(to: selector) {
            saverView.perform(selector, with: defaults)
        }

        for selectorName in ["load_prefs", "load_sim_prefs"] {
            let selector = NSSelectorFromString(selectorName)
            if saverView.responds(to: selector) {
                saverView.perform(selector)
            }
        }
    }

    private func refreshSimulationPreferences(for saverView: ScreenSaverView) {
        let selector = NSSelectorFromString("load_sim_prefs")
        guard saverView.responds(to: selector) else {
            return
        }

        saverView.perform(selector)

        DispatchQueue.main.async {
            saverView.perform(selector)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            saverView.perform(selector)
        }
    }

    private static func matrixDefaults() -> ScreenSaverDefaults? {
        ScreenSaverDefaults(forModuleWithName: "org.indirect.screensaver.Matrix")
    }

    private static func savedExitShortcut() -> ExitShortcut? {
        let defaults = matrixDefaults()
        defaults?.synchronize()
        return ExitShortcut.from(defaults: defaults)
    }

    private static func savedExitOnMouseMovement(defaults: UserDefaults? = matrixDefaults()) -> Bool {
        guard let defaults else {
            return true
        }

        defaults.synchronize()
        guard defaults.object(forKey: exitOnMouseMovementKey) != nil else {
            return true
        }

        return defaults.bool(forKey: exitOnMouseMovementKey)
    }

    private static func shouldExitForKey(_ event: NSEvent, shortcut: ExitShortcut?) -> Bool {
        if let shortcut {
            return shortcut.matches(event)
        }

        return event.type == .keyDown
    }

    private static func shouldExitForModifier(_ event: NSEvent, shortcut: ExitShortcut?) -> Bool {
        guard shortcut == nil else {
            return false
        }

        return event.modifierFlags.intersection(ExitShortcut.relevantModifierFlags).isEmpty == false
    }

    private func shouldExitForMouseInput() -> Bool {
        exitOnMouseMovement
    }

    private func shouldExitForMouseMovement() -> Bool {
        shouldExitForMouseInput() && Date() >= mouseMovementExitArmedAt
    }

    private static func colorFromDefaults(_ defaults: UserDefaults?, key: String) -> NSColor? {
        guard let values = defaults?.array(forKey: key), values.count >= 3 else {
            return nil
        }

        let red = (values[0] as? NSNumber)?.doubleValue ?? 0
        let green = (values[1] as? NSNumber)?.doubleValue ?? 0
        let blue = (values[2] as? NSNumber)?.doubleValue ?? 0
        return NSColor(red: red, green: green, blue: blue, alpha: 1)
    }

    private static func defaultsArray(from color: NSColor) -> [Double] {
        let rgb = color.usingColorSpace(.deviceRGB) ?? color
        return [rgb.redComponent, rgb.greenComponent, rgb.blueComponent]
    }

    private static func defaultColor(at index: Int) -> NSColor {
        switch index {
        case 0:
            return NSColor(red: 0.05, green: 0.95, blue: 0.10, alpha: 1)
        case 1:
            return NSColor(red: 0.40, green: 1.00, blue: 0.45, alpha: 1)
        default:
            return NSColor(red: 0.85, green: 1.00, blue: 0.85, alpha: 1)
        }
    }

    private func fail(_ message: String) {
        fputs("Matrix launcher error: \(message)\n", stderr)
        allowQuit = true
        NSApp.terminate(nil)
    }

    private static func launchOptions() -> (showSettings: Bool, menuBar: Bool, saverURL: URL) {
        var showSettings = false
        var saverPath: String?

        for argument in CommandLine.arguments.dropFirst() {
            switch argument {
            case "--settings", "-s":
                showSettings = true
            case let psnArgument where psnArgument.hasPrefix("-psn_"):
                continue
            default:
                if saverPath == nil {
                    saverPath = argument
                }
            }
        }

        if NSEvent.modifierFlags.contains(.option) {
            showSettings = true
        }

        let hasExplicitSaverPath = saverPath != nil
        let menuBar = !showSettings && !hasExplicitSaverPath && Bundle.main.bundleURL.pathExtension == "app"

        if let saverPath {
            return (showSettings, menuBar, URL(fileURLWithPath: saverPath))
        }

        return (showSettings, menuBar, availableSaverURL() ?? currentDirectorySaverURL())
    }

    private static func bundledSaverURL() -> URL? {
        guard let resourceURL = Bundle.main.resourceURL else {
            return nil
        }

        let bundledSaverURL = resourceURL.appendingPathComponent("Matrix.saver")
        guard FileManager.default.fileExists(atPath: bundledSaverURL.path) else {
            return nil
        }

        return bundledSaverURL
    }

    private static func availableSaverURL() -> URL? {
        if let bundledSaverURL = bundledSaverURL() {
            return bundledSaverURL
        }

        let appSiblingURL = Bundle.main.bundleURL
            .deletingLastPathComponent()
            .appendingPathComponent("Matrix.saver")
        if FileManager.default.fileExists(atPath: appSiblingURL.path) {
            return appSiblingURL
        }

        let currentDirectoryURL = currentDirectorySaverURL()
        if FileManager.default.fileExists(atPath: currentDirectoryURL.path) {
            return currentDirectoryURL
        }

        return nil
    }

    private static func currentDirectorySaverURL() -> URL {
        URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent("Matrix.saver")
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
