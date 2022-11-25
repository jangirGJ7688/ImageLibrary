//
//  ImageData.swift
//  ImageLibrary
//
//  Created by Ganpat Jangir on 10/11/22.
//

import Foundation


struct ImageData : Decodable{
    let total : Int
    let results : [Result]
}

struct Result : Decodable {
    let urls : URL_Object
    let user : User_Object
}

struct URL_Object : Decodable {
    let regular : String
}

struct User_Object : Decodable {
    let name : String
}
