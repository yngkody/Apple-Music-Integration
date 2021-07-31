//
//  Extensions.swift
//  Apple Music Code
//
//  Created by Kody Young on 7/21/21.
//

import Foundation
import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView{

    func loadImagesUsingCacheWithUrlString(urlString: String){
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as?
            UIImage{
            self.image = cachedImage
            return
        }
               if let url = URL(string: urlString){
               URLSession.shared.dataTask(with: url , completionHandler: {( data, response, error) in
                   
                   if error != nil && data == nil{
                       print(error)
                   }
                   else{
                       DispatchQueue.main.async {
                        
                        if let downloadedImage = UIImage(data: data!){
                            imageCache.setObject(downloadedImage, forKey: (urlString as AnyObject))
                            self.image = UIImage(data: data!)
                        }
                       
                       }
                   }
                   
                   }).resume()
           }
    }
}
