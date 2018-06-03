import Cocoa

protocol PlexSweeperDelegate {
    func log(_ string: String)
}

class PlexSweeper {
    
    var delegate: PlexSweeperDelegate?
    
    let moviesUrl: URL
    let untreatedMovies: URL
    
    let showsUrl: URL
    let untreatedShowsUrl: URL
    
    let theMovieDBApiKey: String
    
    private let fileManager = FileManager.default
    
    init(movies: URL, untreatedMovies: URL, shows: URL, untreatedShows: URL, theMovieDBApiKey: String) {
        
        self.moviesUrl = movies
        self.untreatedMovies = untreatedMovies
        self.showsUrl = shows
        self.untreatedShowsUrl = untreatedShows
        
        self.theMovieDBApiKey = theMovieDBApiKey
    }
    
    // MARK: - TV Shows
    
    /// Список скачанных сериалов
    var showsList: [String: URL] = [:]
    
    /// Загружает текущий список сериалов
    func loadShowsList() {
        
        // Пытаемся получить список урлов в директории сериалов
        do {
            
            let urls = try fileManager.contentsOfDirectory(at: showsUrl, includingPropertiesForKeys: nil)
            
            // Составляем список текущих сериалов
            for url in urls where urlIsHiddenFile(url) == false && urlIsVideo(url) == false {
                showsList[url.lastPathComponent] = url
            }
            
        } catch {
            delegate?.log("Error accessing the shows")
        }
    }
    
    /// Разбирает необработанные сериалы
    func sweepUntreatedShows() {
        
        // Обновляем список сериалов
        loadShowsList()
        
        // Пытаемся получить список урлов в папке с необработанными эпизодами
        do {
            
            let urls = try fileManager.contentsOfDirectory(at: untreatedShowsUrl, includingPropertiesForKeys: nil)
            for url in urls where urlIsHiddenFile(url) == false && urlIsVideo(url) {
                
                let fileName = url.lastPathComponent.replacingOccurrences(of: ".", with: " ")
                var isShowExist = false
                
                // Нашли папку с сериалом и закидываем туда файл эпизода
                for (showName, showUrl) in showsList where fileName.lowercased().hasPrefix(showName.lowercased()) {
                    isShowExist = true
                    
                    do {
                        try fileManager.moveItem(at: url, to: showUrl.appendingPathComponent(url.lastPathComponent))
                    } catch {
                        delegate?.log(error.localizedDescription)
                    }
                }
                
                // Если папки с сериалом не существует, то создаем её и закидываем туда файл эпизода
                if isShowExist == false {
                    
                    let showName = showNameFromUrl(url) ?? url.lastPathComponent
                    
                    do {
                        let newShowUrl = showsUrl.appendingPathComponent(showName)
                        
                        // Создаем папку
                        try fileManager.createDirectory(at: newShowUrl, withIntermediateDirectories: true, attributes: nil)
                        
                        // Грузим постер
                        updateShowPoster(url: newShowUrl, needToCompare: false)
                        
                        // Закидываем сериал в новую папку
                        try fileManager.moveItem(at: url, to: newShowUrl.appendingPathComponent(url.lastPathComponent))
                        
                        delegate?.log("Sweep \"\(fileName)\"")
                        
                    } catch {
                        delegate?.log(error.localizedDescription)
                    }
                }
            }
            
        } catch {
            delegate?.log("Error accessing the untreated shows")
        }
        
    }
    
    /// Обновляет постеры сериалов
    func updateShowPosters(status: ((Double) -> Void)? = nil, completion: (() -> Void)? = nil) {
        
        let statusPerShow: Double = 1 / Double(showsList.count)
        
        var currentStatus: Double = statusPerShow
        for (_, showUrl) in showsList {
            updateShowPoster(url: showUrl) {
                                
                status?(currentStatus)
            
                if currentStatus >= 1 {
                    completion?()
                }
                
                currentStatus += statusPerShow
            }
        }
    }
    
    /// Обновляет постер конкретного сериала
    func updateShowPoster(url: URL, needToCompare: Bool = true, completion: (() -> Void)? = nil) {
        
        // Берём название сериала
        let showName = showNameFromUrl(url) ?? url.lastPathComponent
        
        // И грузим постер с TheMovieDB
        let loader = PosterDownloader(apiKey: theMovieDBApiKey)
        loader.downloadShowPoster(name: showName) { (image) in
            
            // Если постер загрузился, то ставим его заместо картинки папки
            if let showPoster = image {
                
                // Конвертируем в .icns
                let icon = self.convertToIcon(image: showPoster)
                
                // Так как, начиная с Sierra, заместо иконки папки можно поставить только квадратную,
                // добавляем прозрачные рамки с двух сторон у постера
                let showImage = self.updateBounds(image: icon!)
                
                // Меняем иконку, если она новая
                let oldShowImage = NSWorkspace.shared.icon(forFile: url.path)
                if self.compareImages(image1: oldShowImage, isEqualTo: showImage) == false || needToCompare == false {
                    NSWorkspace.shared.setIcon(showImage, forFile: url.path, options: .exclude10_4ElementsIconCreationOption)
                }
                
                self.delegate?.log("Downloaded poster for \"\(showName)\"")
                
            } else {
                self.delegate?.log("Error loading poster for \"\(showName)\"")
            }
            
            completion?()
        }
    }
    
    // MARK: - Helpers
    
    /// Проверяет является ли файл по урлу видео
    func urlIsVideo(_ url: URL) -> Bool {
        
        let name = url.lastPathComponent
        
        return name.hasSuffix(".mp4") || name.hasSuffix(".mkv") || name.hasSuffix(".avi")
    }
    
    /// Проверяет является ли файл по урлу скрытым
    func urlIsHiddenFile(_ url: URL) -> Bool {
        
        return url.lastPathComponent.first == "."
    }
    
    /// Возвращает название сериала по урлу
    func showNameFromUrl(_ url: URL) -> String? {
        
        let fileName = url.lastPathComponent
        
        do {
            // С помощью регулярки ищем идентификатора сериала
            let regex = try NSRegularExpression(pattern: "(?=S\\d{1,2}E\\d{1,2})")
            
            // Всё, что до этого идентификатора, является названием сериала
            let range = regex.rangeOfFirstMatch(in: fileName, range: NSRange(location: 0, length: fileName.count))
            if range != NSRange(location: NSNotFound, length: 0) {
                
                // Убираем точки, если они есть
                let showName = fileName.prefix(upTo: fileName.index(fileName.startIndex, offsetBy: range.location - 1)).replacingOccurrences(of: ".", with: " ")
                return showName
            }
            
            return nil
            
        } catch {
            delegate?.log(error.localizedDescription)
            return nil
        }
    }
    
    /// Обновляет границы картинки, делая её квадратной
    func updateBounds(image: NSImage) -> NSImage {
        
        let bitmap = image.representations[0]
        let imageSize = NSSize(width: bitmap.pixelsHigh, height: bitmap.pixelsHigh)
        
        let borderedImage = NSImage(size: imageSize)
        
        borderedImage.lockFocus()
        
        NSColor.clear.setFill()
        NSBezierPath.fill(NSRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        
        var newImageRect = CGRect.zero
        newImageRect.size = borderedImage.size
        
        var oldImageRect = CGRect.zero
        oldImageRect.size = image.size
        oldImageRect.origin.x = (image.size.height - image.size.width) / 2
        oldImageRect.origin.y = 0
        
        borderedImage.draw(in: newImageRect)
        image.draw(in: oldImageRect)
        
        borderedImage.unlockFocus()
        
        return borderedImage
    }
    
    // Конвертирует картинку в .icns
    func convertToIcon(image: NSImage) -> NSImage? {
    
        var imageData = image.tiffRepresentation
        let imageRep = NSBitmapImageRep(data: imageData!)
        let imageProps = [NSBitmapImageRep.PropertyKey.compressionFactor: 1.0]
        
        imageData = imageRep?.representation(using: .jpeg, properties: imageProps)
        
        do {
            let savedUrl = untreatedShowsUrl.appendingPathComponent("savedPoster.icns")
            
            try imageData?.write(to: savedUrl)
            let icon = NSImage(contentsOf: savedUrl)
            try fileManager.removeItem(at: savedUrl)
            
            return icon
            
        } catch {
            return nil
        }
    }
    
    // Сравнивает картинки
    func compareImages(image1: NSImage, isEqualTo image2: NSImage) -> Bool {

        let data1: NSData = image1.tiffRepresentation! as NSData
        let data2: NSData = image1.tiffRepresentation! as NSData

        return data1.isEqual(data2)
    }
}
