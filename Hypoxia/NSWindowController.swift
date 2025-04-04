import Cocoa
import SwiftUI

class OverlayWindowController: NSWindowController {
    
    convenience init(blinkInterval: Double) {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: NSScreen.main?.frame.width ?? 1920, height: NSScreen.main?.frame.height ?? 1080),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        let overlayView = OverlayView(blinkInterval: blinkInterval)
        let hostingController = NSHostingController(rootView: overlayView)
        window.contentViewController = hostingController
        
        self.init(window: window)
        
        // Configure the window immediately
        configureWindow()
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        print("Window did load")
        configureWindow()
    }
    
    private func configureWindow() {
        guard let window = self.window else {
            print("Window not available for configuration")
            return
        }
        
        // Set window to be transparent
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        
        // Make window float above all other windows and ignore mouse events
        window.level = .statusBar
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.isMovableByWindowBackground = false
        
        // Set the window to cover the entire screen
        if let screen = NSScreen.main {
            window.setFrame(screen.frame, display: true)
        }
        
        // Ensure window is visible
        window.orderFrontRegardless()
        window.makeKey()
        
        print("Window configured with level: \(window.level.rawValue), mouse events ignored: \(window.ignoresMouseEvents)")
    }
}
