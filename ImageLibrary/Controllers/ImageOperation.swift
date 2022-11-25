//
//  ImageOperation.swift
//  ImageLibrary
//
//  Created by Ganpat Jangir on 07/11/22.
//

import Foundation
import UIKit


enum ImageState {
    case downloaded, saved , new
}

class Image {
    let url : URL
    var state = ImageState.new
    var image = UIImage(named: "img")
    init(url : URL) {
        self.url = url
    }
}

class ImageOperationManager {
    var downloadsInProgress: [IndexPath: Operation] = [:]
    var downloadQueue : OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download Queue"
        return queue
    }()
    var saveToDiskInProgress: [IndexPath: Operation] = [:]
    var saveToDiskQueue : OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Save To Disk Queue"
        queue.maxConcurrentOperationCount = 1   // For making queue serial
        return queue
    }()
}


class ImageDownloader : Operation {
    
    let image : Image
    init(_ image : Image) {
        self.image = image
    }
    
    override func main() {
        if isCancelled {
            return
        }
        guard let imageData = try? Data(contentsOf: image.url) else { return }
        
        if isCancelled {
            return
        }
        if !imageData.isEmpty {
            print("Image is Downloaded")
            image.image = UIImage(data: imageData)
            image.state = ImageState.downloaded
        }
    }
}

enum CreateFolderResponse {
    case alreadyCreated,created,error
}

class ImageSaveToDisk : Operation {
    let image : Image
//    let folderName = "ImageLibrary"
    let diskOperations = DiskOperations()
    init(_ image : Image){
        self.image = image
    }
    
    override func main() {
        guard diskOperations.createFolderIfNeeded() != CreateFolderResponse.error else { return }
        let imageName = image.url.path
        if imageName.isEmpty {
            return
        }
        if let imageGetFromDisk = diskOperations.getImageFromDisk(key: imageName) {
            image.image = imageGetFromDisk
        }else {
            if diskOperations.addImageToDisk(key: imageName, value: image.image!) {
                image.state = ImageState.saved
            }
        }
    }
}


class DiskOperations {
    let folderName = "ImageLibrary"
    
    func createFolderIfNeeded() -> CreateFolderResponse{
        guard let url = getFolderPath() else { return CreateFolderResponse.error}
        if !FileManager.default.fileExists(atPath: url.path){
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                print("Created Folder")
                return CreateFolderResponse.created
            } catch let error {
                print("Error creating folder. \(error)")
                return CreateFolderResponse.error
            }
        }else {
            return CreateFolderResponse.alreadyCreated
        }
    }
    
    func getFolderPath() -> URL? {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent(folderName)
    }
    
    func getImagePath(key : String) -> URL? {
        guard let folder = getFolderPath() else { return nil }
        return folder.appendingPathComponent(key + ".jpeg")
    }
    
    func getImageFromDisk(key : String) ->UIImage? {
        guard let url = getImagePath(key: key),FileManager.default.fileExists(atPath: url.path) else { return nil}
        print("Image is getting from disk")
        return UIImage(contentsOfFile: url.path)
    }
    
    func addImageToDisk(key : String,value : UIImage) -> Bool {
        guard let data = value.jpegData(compressionQuality: 1.0),
              let url = getImagePath(key: key) else { return false}
        do {
            try data.write(to: url)
            return true
        } catch let error {
            print("Error saving to the file manager \(error)")
            return false
        }
    }
}
