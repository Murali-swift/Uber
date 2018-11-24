//
//  PhotoCollectionViewCell.swift
//  Uber
//
//  Created by Murali on 24/11/18.
//  Copyright © 2018 MuraliNallusamy. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    var urlSession : URLSessionDataTask? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateImage(photoUrl:URL?){
        photoImageView.image = nil
        
        if urlSession != nil {
            urlSession?.cancel()
        }
        
        if let url = photoUrl {
            photoImageView.contentMode = .scaleAspectFit
            urlSession = photoImageView.downloaded(from: url)
        }
    }

}


