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
        
        // Update frame to current window
//        if let mainScreenFrame = NSScreen.screens.first?.frame, let sweeperWindowFrame = sweeperWindowController?.window?.frame {
//            let position: NSPoint = NSPoint(x: mainScreenFrame.width - sweeperWindowFrame.width, y: sweeperWindowFrame.origin.y)
//            sweeperWindowController?.window?.setFrame(NSRect(x: position.x, y: position.y, width: sweeperWindowFrame.width, height: sweeperWindowFrame.height), display: true)
//        }
        
        // Show window
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

class AppSettings {
    
    static let shared = AppSettings()
    
    static private let moviesUrlKey = "MoviesUrl"
    static private let showsUrlKey = "ShowsUrl"
    static private let untreatedMoviesUrlKey = "UntreatedMoviesUrl"
    static private let untreatedShowsUrlKey = "UntreatedShowsUrl"

    var moviesUrl: URL {
        get {
            guard let url = UserDefaults.standard.url(forKey: AppSettings.moviesUrlKey) else {
                let defaultUrl = FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask)[0].appendingPathComponent("Movies", isDirectory: true)
                
                // Safe default url
                self.moviesUrl = defaultUrl
                
                return defaultUrl
            }

            return url
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: AppSettings.moviesUrlKey)
        }
    }
    
    var showsUrl: URL {
        get {
            guard let url = UserDefaults.standard.url(forKey: AppSettings.showsUrlKey) else {
                let defaultUrl = FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask)[0].appendingPathComponent("TV Shows", isDirectory: true)
                
                // Safe default url
                self.showsUrl = defaultUrl
                
                return defaultUrl
            }
            
            return url
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: AppSettings.showsUrlKey)
        }
    }
    
    var untreatedMoviesUrl: URL {
        get {
            guard let url = UserDefaults.standard.url(forKey: AppSettings.untreatedMoviesUrlKey) else {
                let defaultUrl = FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask)[0].appendingPathComponent("Untreated/Movies", isDirectory: true)
                
                // Safe default url
                self.untreatedMoviesUrl = defaultUrl
                
                return defaultUrl
            }
            
            return url
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: AppSettings.untreatedMoviesUrlKey)
        }
    }
    
    var untreatedShowsUrl: URL {
        get {
            guard let url = UserDefaults.standard.url(forKey: AppSettings.untreatedShowsUrlKey) else {
                let defaultUrl = FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask)[0].appendingPathComponent("Untreated/TV Shows", isDirectory: true)
                
                // Safe default url
                self.untreatedShowsUrl = defaultUrl
                
                return defaultUrl
            }
            
            return url
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: AppSettings.untreatedShowsUrlKey)
        }
    }
}
