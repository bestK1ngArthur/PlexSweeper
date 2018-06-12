//
//  ViewController.swift
//  PlexSweeper
//
//  Created by Arthur K1ng on 27/05/2018.
//  Copyright © 2018 Artem Belkov. All rights reserved.
//

import Cocoa

class SweeperController: NSViewController, PlexSweeperDelegate {
    
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet var consoleView: NSTextView!
    
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var indicator: NSProgressIndicator!
    
    @IBOutlet weak var sweepButton: NSButton!
    
    var sweeper: PlexSweeper?
    
    var moviesObserver: DirectoryObserver?
    var showsObserver: DirectoryObserver?
    
    // MARK: API
    
    let theMovieDBApiKey = "f11f0534c3e09c599e78ceadcdb91b32"
    
    // MARK: - Folders
    
    // Папки для Plex
    let moviesUrl = FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask)[0].appendingPathComponent("Movies", isDirectory: true)
    let showsUrl = FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask)[0].appendingPathComponent("TV Shows", isDirectory: true)
    
    // Папки для необработанных файлов
    let untreatedMoviesUrl = FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask)[0].appendingPathComponent("Untreated/Movies", isDirectory: true)
    let untreatedShowsUrl = FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask)[0].appendingPathComponent("Untreated/TV Shows", isDirectory: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareUI()
        
        sweeper = PlexSweeper(movies: moviesUrl, untreatedMovies: untreatedMoviesUrl, shows: showsUrl, untreatedShows: untreatedShowsUrl, theMovieDBApiKey: theMovieDBApiKey)
        sweeper?.delegate = self
        
        moviesObserver = DirectoryObserver(url: untreatedMoviesUrl, block: {
            self.sweeper?.sweepUntreatedMovies()
        })
        showsObserver = DirectoryObserver(url: untreatedShowsUrl, block: {
            self.sweeper?.sweepUntreatedShows()
        })
    }
    
    func prepareUI() {
    
        titleLabel.textColor = NSColor(named: NSColor.Name("titleColor"))
    }
    
    // MARK: - Actions
    
    @IBAction func sweepShowsAction(_ sender: Any) {
        log("Start sweeping")
        
        // Обрабатываем фильмы.
        sweeper?.sweepUntreatedMovies()

        // Обрабатываем сериалы.
        sweeper?.sweepUntreatedShows()
        
        log("Finish sweeping")
    }
    
    @IBAction func updateShowPostersAction(_ sender: Any) {
        sweeper?.loadShowsList()

        indicator.doubleValue = 0
        indicator.isHidden = false
        
        log("Start downloading posters")
        sweeper?.updateShowPosters(status: { status in
            
            DispatchQueue.main.async {
                self.indicator.doubleValue = status * 100
            }
            
        }, completion: {
            DispatchQueue.main.async {
                self.indicator.isHidden = true
                self.log("Finish loading posters")
            }
        })
    }
    
    // MARK: - Log
    
    func log(_ string: String) {
        
        DispatchQueue.main.async {

            self.consoleView.scrollLineDown(self)
            
            let list = string.components(separatedBy: "\"")
            
            for (index, component) in list.enumerated() {
                
                var attributes: [NSAttributedStringKey : Any] = [.foregroundColor: NSColor(named: NSColor.Name("titleColor")) ?? NSColor.white]
                
                // Если нужно выделить строку
                if index % 2 != 0 {
                    attributes[NSAttributedStringKey.font] = NSFont.boldSystemFont(ofSize: 12)
                } else {
                    attributes[NSAttributedStringKey.font] = NSFont.systemFont(ofSize: 12)
                }
                
                self.consoleView.textStorage?.append(NSAttributedString(string: "\(component)", attributes: attributes))
            }
            
            self.consoleView.textStorage?.append(NSAttributedString(string: "\n"))
        }
    }
}
