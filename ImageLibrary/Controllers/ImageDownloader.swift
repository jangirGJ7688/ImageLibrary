//
//  ImageDownloader.swift
//  ImageLibrary
//
//  Created by Ganpat Jangir on 04/11/22.
//

import Foundation
import UIKit


class ImageDownloader {
    
    static let shared = ImageDownloader()
    
    private var cachedImages : [String : UIImage]
    
    private init() {
        cachedImages = [:]
    }
    func downloadImage(with imageURLString : String?,
                       completionHandler : @escaping (UIImage?,Bool)->Void,
                       placeholderImage :UIImage?){
        guard let imageURLString = imageURLString else {
            completionHandler(placeholderImage,true)
            return
        }
        
        if let image = getCachedImageFrom(urlString : imageURLString){
            print("Image is getting from cache")
            completionHandler(image,true)
        }else{
            guard let url = URL(string: imageURLString) else {
                completionHandler(placeholderImage,true)
                return
            }
            print("Image is getting downloading")
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data else {
                    return
                }
                if let _ = error {
                    DispatchQueue.main.async {
                        completionHandler(placeholderImage,true)
                    }
                    return
                }
                let image = UIImage(data : data)
                self.cachedImages[imageURLString] = image
                DispatchQueue.main.async {
                    completionHandler(image,false)
                }
            }
            task.resume()
        }

    }
    
    private func getCachedImageFrom(urlString : String) -> UIImage? {
        return cachedImages[urlString]
    }

}

