//
//  Photo.swift
//  Uber
//
//  Created by Murali on 24/11/18.
//  Copyright © 2018 MuraliNallusamy. All rights reserved.
//

import Foundation

struct Photo {
    var id: String
    var secret: String
    var server: String
    var farm: Int
    var title: String
    
    var photoUrl: URL! {
        return URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_m.jpg")!
    }
}
