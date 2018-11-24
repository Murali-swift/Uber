//
//  ViewController.swift
//  Uber
//
//  Created by Murali on 24/11/18.
//  Copyright © 2018 MuraliNallusamy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let photomanager = PhotoManager()
    var footerView:RefreshFooterView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        photoCollectionView.register(UINib.init(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCollectionViewCell")

    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photomanager.photo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        let photo  = photomanager.photo[indexPath.row]
        if let url = photo.photoUrl {
            cell.updateImage(photoUrl: url)
        }else {
            cell.updateImage(photoUrl: nil)
        }
        
        photomanager.nextPage(currentRow: indexPath) { (photo, error) in
            DispatchQueue.main.async {
                if error != nil {
                    print(error!)
                    let alert = UIAlertController(title: "Alert", message: error?.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        switch action.style{
                        case .default:
                            print("default")
                            
                        case .cancel:
                            print("cancel")
                            
                        case .destructive:
                            print("destructive")
                            
                            
                        }}))
                    self.present(alert, animated: true, completion: nil)
                }else {
                    self.photoCollectionView.reloadData()
                }
            }
     
        }
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let aFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constant.footerViewReuseIdentifier, for: indexPath) as! RefreshFooterView
            self.footerView = aFooterView
            self.footerView?.backgroundColor = UIColor.clear
            return aFooterView
        }
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            if !photomanager.isReachedLast {
                self.footerView?.prepareInitialAnimation()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            self.footerView?.stopAnimate()
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = Double(collectionView.frame.width) - Constant.dynamicCellSpaceing
        let cellWidth = CGFloat( width / Constant.photosCountInColumn)
        return CGSize(width: cellWidth, height: cellWidth + 35.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    //compute the scroll value and play witht the threshold to get desired effect
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let threshold   = 100.0
        let diffHeight = scrollView.contentSize.height - scrollView.contentOffset.y
        let frameHeight = scrollView.bounds.size.height
        let triggerThreshold = min(Float((diffHeight - frameHeight))/Float(threshold), 0.0)
        let pullRatio  = min(abs(triggerThreshold),1.0)
        self.footerView?.setTransform(inTransform: CGAffineTransform.identity, scaleFactor: CGFloat(pullRatio))
        if pullRatio >= 0.5 {
            if !photomanager.isReachedLast{
                self.footerView?.animateFinal()
            }
        }
    }

    //compute the offset and call the load method
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let diffHeight = scrollView.contentSize.height - scrollView.contentOffset.y
        let pullHeight  = abs(diffHeight - scrollView.bounds.size.height)
        if pullHeight == 0.0
        {
            if (self.footerView?.isAnimatingFinal)! {
                print("load more trigger")
                if !photomanager.isReachedLast{
                    self.footerView?.startAnimate()
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
       
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty == true {
            //            clear
            self.searchBar.endEditing(true)
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        photomanager.removeAllPhotos()
        if let search = searchBar.text {
            if search.isEmpty {
                //            clear
                searchBar.showsCancelButton = false
            }else {
                activityIndicator.startAnimating()
                photomanager.search(search) { (photo, error) in
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        if error != nil {
                            print(error!)
                            let alert = UIAlertController(title: "Alert", message: error?.localizedDescription, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                switch action.style{
                                case .default:
                                    print("default")
                                    
                                case .cancel:
                                    print("cancel")
                                    
                                case .destructive:
                                    print("destructive")
                                    
                                    
                                }}))
                            self.present(alert, animated: true, completion: nil)
                        }else {
                            self.photoCollectionView.reloadData()
                             self.photoCollectionView.selectItem(at: IndexPath.init(row: 0, section: 0), animated:false, scrollPosition: .centeredVertically)
                        }
                    }
                    
                }
            }
        }
       
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
        //            clear
        searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
}
