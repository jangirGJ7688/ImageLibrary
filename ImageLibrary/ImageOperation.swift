//
//  ImageOperation.swift
//  ImageLibrary
//
//  Created by Ganpat Jangir on 03/11/22.
//

import Foundation
import UIKit


class ImageRecord {
    var url : URL
    let date = Date()
    init(url : URL){
        self.url = url
    }
}


class ImageDownloader : Operation {
    let imageRecord : ImageRecord
    
    init(_ imageRecord : ImageRecord){
        self.imageRecord = imageRecord
    }
}


class ImageSave : Operation {
    
}
