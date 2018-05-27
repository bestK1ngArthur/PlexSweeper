//
//  DirectoryObserver.swift
//  PlexSweeper
//
//  Created by Arthur K1ng on 27/05/2018.
//  Copyright © 2018 Artem Belkov. All rights reserved.
//

import Cocoa

class DirectoryObserver {
    
    private let fileDescriptor: CInt
    private let source: DispatchSourceProtocol
    
    deinit {
        
        self.source.cancel()
        close(fileDescriptor)
    }
    
    init(url: URL, block: @escaping ()->Void) {
        
        self.fileDescriptor = open(url.path, O_EVTONLY)
        self.source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: self.fileDescriptor, eventMask: .all, queue: DispatchQueue.global())
        self.source.setEventHandler {
            block()
        }
        self.source.resume()
    }
}
