//
//  AppDelegate.swift
//  PlexSweeper
//
//  Created by Arthur K1ng on 27/05/2018.
//  Copyright © 2018 Artem Belkov. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    var sweeperWindowController: NSWindowController?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {

        // Add status bar button
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarImage"))
            button.action = #selector(showWindow)
        }
        
        sweeperWindowController = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "MainWindowController")) as? NSWindowController
        sweeperWindowController?.window?.delegate = self
        sweeperWindowController?.showWindow(self)
        sweeperWindowController?.window?.orderOut(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    // MARK: - Window
    
    @objc func showWindow() {
        sweeperWindowController?.window?.orderFrontRegardless()
    }
    
    // MARK: - NSWindowDelegate
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        
        // If window is sweeper window, deny to close the window
        if sender.isEqual(sweeperWindowController?.window) {
            sender.orderOut(self)
            
            return false
        }
        
        return true
    }
}
