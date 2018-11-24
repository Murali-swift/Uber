//
//  PhotoManager.swift
//  Uber
//
//  Created by Murali on 24/11/18.
//  Copyright © 2018 MuraliNallusamy. All rights reserved.
//

import Foundation

class PhotoManager {
    var totalPhotos: Int = 0
    var totalPage: Int = 1
    var perPage: Int = 20
    var photo: [Photo] = []
    var searchContent: String?
    var taskSession:URLSessionDataTask? = nil
    var currentPage: Int = 1 {
        didSet {
            if currentPage * perPage >= totalPhotos {
                isReachedLast = true
            }else {
                isReachedLast = false
            }
        }
    }
    
    var isReachedLast = false
    
    
    func search(_ content:String, completion:@escaping ([Photo],Error?)->()) {
        searchContent = content
        let flickrString = Constant.url(withManager: self, andSearchString: searchContent ?? "")
        guard let requestUrl = URL(string:flickrString) else {
            let invalidURL = NSError(domain: "com.flickr.api", code: 404, userInfo: nil)
            completion([], invalidURL)
            return
        }
        taskSession = URLSession.shared.dataTask(with: URLRequest(url:requestUrl)) {
            (data, response, error) in
            self.taskSession = nil

            if error != nil {
                print("Error fetching photos: \(error ?? "" as! Error)")
                completion([], error as NSError?)
                return
            }
            do {
                let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject]
                
                guard let results = parsedData else { return }
                
                if let statusCode = results["stat"] as? String {
                    if statusCode != Constant.invalidAccessErrorCode {
                        let invalidAccessError = NSError(domain: "com.flickr.api", code: 100, userInfo: nil)
                        completion([], invalidAccessError)
                        return
                    }
                }

                guard let photosContainer = parsedData!["photos"] as? NSDictionary else {
                    let invalidError = NSError(domain: "com.flickr.api", code: 422, userInfo: nil)
                    completion([], invalidError)
                    return
                }
                guard let photosArray = photosContainer["photo"] as? [NSDictionary] else {
                    let invalidError = NSError(domain: "com.flickr.api", code: 422, userInfo: nil)
                    completion([], invalidError)
                    return
                }
                self.perPage = photosContainer["perpage"] as? Int ?? 1
                self.totalPage = photosContainer["pages"] as? Int ?? 1
                self.totalPhotos = Int(photosContainer["total"] as? String ?? "1") ?? 1
                self.currentPage = photosContainer["page"] as? Int ?? 1
                
                let flickrPhotos: [Photo] = photosArray.map { photoDictionary in
                    let id = photoDictionary["id"] as? String ?? ""
                    let farm = photoDictionary["farm"] as? Int ?? 0
                    let secret = photoDictionary["secret"] as? String ?? ""
                    let server = photoDictionary["server"] as? String ?? ""
                    let title = photoDictionary["title"] as? String ?? ""
                    let flickrPhoto = Photo(id: id, secret: secret, server: server, farm: farm, title: title)

                    return flickrPhoto
                }
                self.currentPage += 1
                self.photo.append(contentsOf: flickrPhotos)
                completion(self.photo, nil)
                
            }
            catch let parsingError as NSError {
                print("Details of JSON parsing error:\n \(parsingError)")
                completion([],parsingError)
            }
        }
        taskSession?.resume()
    }
    
    func nextPage(currentRow:IndexPath, completion:@escaping ([Photo],Error?)->()){
        if (taskSession == nil) && (currentRow.row + 1) >= (photo.count-1) {
            if !isReachedLast{
                search(searchContent ?? "", completion: completion)
            }
        }
    }
    
    func removeAllPhotos(){
        photo.removeAll()
        resetPagination()
    }
    
    private func resetPagination() {
        totalPhotos = 0
        totalPage = 1
        perPage = 20
        taskSession?.cancel()
        taskSession = nil
    }
}
