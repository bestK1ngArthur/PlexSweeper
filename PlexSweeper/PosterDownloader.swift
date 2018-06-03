//
//  PosterDownloader.swift
//  PlexSweeper
//
//  Created by Arthur K1ng on 27/05/2018.
//  Copyright © 2018 Artem Belkov. All rights reserved.
//

import Cocoa

class PosterDownloader {

    private let baseUrl = "https://api.themoviedb.org"
    private let fileUrl = "https://image.tmdb.org/t/p/original"
    private let language = "en-US"
    
    private let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func downloadShowPoster(name: String, completion: @escaping (NSImage?) -> Void) {
        
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let findUrl = URL(string: "\(baseUrl)/3/search/tv?api_key=\(apiKey)&language=\(language)&query=\(encodedName)&page=1")!
        let findTask = URLSession.shared.dataTask(with: findUrl) { (data, response, error) in
            
            guard let data = data else {
                completion(nil)
                return
            }
    
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    
                // Очень больной парсинг для получения пути до постера
                if let posterPath = ((json!["results"] as! [Any])[0] as! [String: Any])["poster_path"] {
                    
                    guard let posterUrl = URL(string: "\(self.fileUrl)\(posterPath)") else {
                        completion(nil)
                        return
                    }
                    
                    let posterRequest = URLRequest(url: posterUrl)
                    let posterTask = URLSession.shared.dataTask(with: posterRequest, completionHandler: { (data, response, error) in
                        
                        if let data = data, error == nil {
                            let image = NSImage(data: data)
                            
                            completion(image)
                            
                        } else {
                            completion(nil)
                        }
                    })
                    
                    posterTask.resume()
                    
                } else {
                    completion(nil)
                }
                
            } catch {
                print(error.localizedDescription)
                completion(nil)
            }
        }
        
        findTask.resume()
    }
}
