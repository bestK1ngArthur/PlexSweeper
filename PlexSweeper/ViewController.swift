//
//  ViewController.swift
//  PlexSweeper
//
//  Created by Arthur K1ng on 27/05/2018.
//  Copyright © 2018 Artem Belkov. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, PlexSweeperDelegate {
    
    @IBOutlet var consoleView: NSTextView!
    @IBOutlet weak var indicator: NSProgressIndicator!
    
    var sweeper: PlexSweeper?
    
    var moviesObserver: DirectoryObserver?
    var showsObserver: DirectoryObserver?
    
    // MARK: API
    
    let theMovieDBApiKey = "your api key"
    
    // MARK: - Folders
    
    // Папки для Plex
    let moviesUrl = FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask)[0].appendingPathComponent("Movies", isDirectory: true)
    let showsUrl = FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask)[0].appendingPathComponent("TV Shows", isDirectory: true)
    
    // Папки для необработанных файлов
    let untreatedMoviesUrl = FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask)[0].appendingPathComponent("Untreated/Movies", isDirectory: true)
    let untreatedShowsUrl = FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask)[0].appendingPathComponent("Untreated/TV Shows", isDirectory: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sweeper = PlexSweeper(movies: moviesUrl, untreatedMovies: untreatedMoviesUrl, shows: showsUrl, untreatedShows: untreatedShowsUrl, theMovieDBApiKey: theMovieDBApiKey)
        sweeper?.delegate = self
        
        moviesObserver = DirectoryObserver(url: untreatedMoviesUrl, block: {
            // BOOM!
        })
        showsObserver = DirectoryObserver(url: untreatedShowsUrl, block: {
            self.log("Начинаем уборку сериальчиков..")
            self.sweeper?.sweepUntreatedShows()
            self.log("В сериальчиках прибрались")
        })
    }
    
    // MARK: - Actions
    
    @IBAction func sweepShowsAction(_ sender: Any) {
        sweeper?.loadShowsList()
        sweeper?.sweepUntreatedShows()
    }
    
    @IBAction func updateShowPostersAction(_ sender: Any) {
        sweeper?.loadShowsList()

        indicator.doubleValue = 0
        indicator.isHidden = false
        
        log("Начинаем грузить постеры..")
        sweeper?.updateShowPosters(status: { status in
            
            DispatchQueue.main.async {
                self.indicator.doubleValue = status * 100
            }
        }, completion: {
            DispatchQueue.main.async {
                self.indicator.isHidden = true
                self.log("Закончили грузить постеры")
            }
        })
    }
    
    // MARK: - Log
    
    func log(_ string: String) {
        
        DispatchQueue.main.async {
            self.consoleView.textStorage?.append(NSAttributedString(string: "\(string)\n"))
            self.consoleView.scrollLineDown(self)
        }
    }
}
