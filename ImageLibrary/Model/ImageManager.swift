//
//  ImageManager.swift
//  ImageLibrary
//
//  Created by Ganpat Jangir on 10/11/22.
//

import Foundation


enum APIError: Error {
    case invalidUrl
    case errorDecode
    case failed(error: Error)
    case unknownError
}


struct ImageManager {
    static let shared = ImageManager()
    let client_id = "lFQJkYI5VMPuqnNDIGjEm_mej86E3-Pm22JtvpJwgik"
    let photoSearchUrl = "https://api.unsplash.com/search/photos?"
    
    
    func getPhotoData(page : Int = 1,imageToSearch : String, completion: @escaping (Swift.Result<[Image]?,APIError>) -> Void){
        let urlString = "\(photoSearchUrl)page=\(page)&per_page=30&query=\(imageToSearch)&client_id=\(client_id)"
        let urlMaded = URL(string: urlString)
        guard let url = urlMaded else{
            completion(.failure(.invalidUrl))
            return
        }
        let urlRequest = URLRequest(url: url,timeoutInterval: 2)
        URLSession.shared.dataTask(with: urlRequest){ data,response,error in
            if error != nil {
                print("dataTask error: \(String(describing: error?.localizedDescription))")
                completion(.failure(.failed(error: error!)))
            }else if let data = data {
                do {
                    let photoData = try JSONDecoder().decode(ImageData.self,from: data)
                    print("succes")
                    var urlStringArray : [Image] = []
                    for urlString in photoData.results {
                        let url = URL(string: urlString.urls.regular)
                        let imageObject = Image(url: url!)
                        urlStringArray.append(imageObject)
                    }
                    completion(.success(urlStringArray))
                } catch {
                    print("decoding error")
                    completion(.failure(.errorDecode))
                }
            }else{
                print("unknown dataTask error")
                completion(.failure(.unknownError))
            }
        }.resume()
    }
}
