//
//  Constant.swift
//  Uber
//
//  Created by Murali on 24/11/18.
//  Copyright © 2018 MuraliNallusamy. All rights reserved.
//

import Foundation

enum Constant {
    static let baseSearchURL = "https://api.flickr.com/services/rest/?method=flickr.photos.search"
    static let apiKey = "3e7cc266ae2b0e0d78e279ce8e361736"
    static let format = "json"
    static let footerViewReuseIdentifier = "RefreshFooterView"

    static func url(withManager:PhotoManager, andSearchString: String)->String{
        let manager = withManager
        let escapedString = andSearchString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)

        return Constant.baseSearchURL + "&api_key=" + Constant.apiKey + "&format=" + Constant.format + "&nojsoncallback=1&safe_search=1" + "&per_page=\(manager.perPage)" + "&text=\(escapedString ?? "")" + "&page=\(manager.currentPage)"
    }
    
   static let invalidAccessErrorCode = "ok"

   static let photosCountInColumn: Double  = 3.0
   static let dynamicCellSpaceing: Double = (photosCountInColumn * 10.0)+20.0
    
}

