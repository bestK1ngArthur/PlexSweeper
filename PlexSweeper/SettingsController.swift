//
//  SettingsController.swift
//  PlexSweeper
//
//  Created by Arthur K1ng on 04/11/2018.
//  Copyright © 2018 Artem Belkov. All rights reserved.
//

import Cocoa

class SettingsController: NSViewController {

    @IBOutlet weak var moviesPathControl: NSPathControl!
    @IBOutlet weak var untreatedMoviesPathControl: NSPathControl!
    
    @IBOutlet weak var showsPathControl: NSPathControl!
    @IBOutlet weak var untreatedShowsPathControl: NSPathControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moviesPathControl.url = AppSettings.shared.moviesUrl
        untreatedMoviesPathControl.url = AppSettings.shared.untreatedMoviesUrl
        
        showsPathControl.url = AppSettings.shared.showsUrl
        untreatedShowsPathControl.url = AppSettings.shared.untreatedShowsUrl
    }
    
    @IBAction func saveAction(_ sender: Any) {
        
        if let moviesUrl = moviesPathControl.url {
            AppSettings.shared.moviesUrl = moviesUrl
        }
        
        if let untreatedMoviesUrl = untreatedMoviesPathControl.url {
            AppSettings.shared.untreatedMoviesUrl = untreatedMoviesUrl
        }
        
        if let showsUrl = showsPathControl.url {
            AppSettings.shared.showsUrl = showsUrl
        }
        
        if let untreatedShowsUrl = untreatedShowsPathControl.url {
            AppSettings.shared.untreatedShowsUrl = untreatedShowsUrl
        }
        
        self.closeAction(self)
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.view.window?.close()
    }
}
