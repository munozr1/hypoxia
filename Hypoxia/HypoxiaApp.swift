//
//  HypoxiaApp.swift
//  Hypoxia
//
//  Created by Rodrigo Munoz on 4/4/25.
//

import SwiftUI

@main
struct HypoxiaApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            // Empty settings scene - all controls are in the status bar
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    var statusItem: NSStatusItem?
    var overlayWindowController: OverlayWindowController?
    @Published var blinkInterval: Double = 120.0 // Default: 2 minutes
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("Application did finish launching")
        
        // Hide app from Dock
        NSApp.setActivationPolicy(.accessory)
        
        setupStatusBarItem()
        setupOverlayWindow()
        
        // Register for notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBlinkTrigger),
            name: .triggerBlink,
            object: nil
        )
    }
    
    func setupStatusBarItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.image = NSImage(systemSymbolName: "eye", accessibilityDescription: "Hypoxia")
        
        let menu = NSMenu()
        
        // Add interval options
        let intervalMenu = NSMenu()
        addIntervalItem(to: intervalMenu, title: "30 seconds", interval: 30.0)
        addIntervalItem(to: intervalMenu, title: "1 minute", interval: 60.0)
        addIntervalItem(to: intervalMenu, title: "1.5 minutes", interval: 90.0)
        addIntervalItem(to: intervalMenu, title: "2 minutes", interval: 120.0)
        
        let intervalItem = NSMenuItem(title: "Blink Interval", action: nil, keyEquivalent: "")
        intervalItem.submenu = intervalMenu
        menu.addItem(intervalItem)
        
        // Add test blink option
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Test Blink", action: #selector(triggerBlinkNow), keyEquivalent: "t"))
        
        // Add quit option
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    private func addIntervalItem(to menu: NSMenu, title: String, interval: Double) {
        let item = NSMenuItem(title: title, action: #selector(changeInterval(_:)), keyEquivalent: "")
        item.tag = Int(interval)
        item.state = interval == blinkInterval ? .on : .off
        menu.addItem(item)
    }
    
    @objc func changeInterval(_ sender: NSMenuItem) {
        // Update interval
        blinkInterval = Double(sender.tag)
        print("Changed blink interval to \(blinkInterval) seconds")
        
        // Update checkmarks
        if let intervalMenu = sender.menu {
            for item in intervalMenu.items {
                item.state = item == sender ? .on : .off
            }
        }
        
        // Notify of interval change
        NotificationCenter.default.post(name: .blinkIntervalChanged, object: nil, userInfo: ["interval": blinkInterval])
    }
    
    @objc func triggerBlinkNow() {
        print("Posting triggerBlink notification from status bar")
        NotificationCenter.default.post(name: .triggerBlink, object: nil)
    }
    
    @objc func handleBlinkTrigger(_ notification: Notification) {
        print("AppDelegate received blink trigger notification")
    }
    
    private func setupOverlayWindow() {
        // Create overlay window if it doesn't exist
        if overlayWindowController == nil {
            overlayWindowController = OverlayWindowController(
                blinkInterval: blinkInterval
            )
            overlayWindowController?.window?.title = "OverlayWindow"
            overlayWindowController?.showWindow(nil)
            print("Created new overlay window")
        }
    }
}
