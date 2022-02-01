//
//  UIImageViewExtension.swift
//  StajProjesi

import UIKit

let imageCachce = NSCache<NSURL, UIImage>()

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        if let cachedImage = imageCachce.object(forKey: url as NSURL) {
            self.image = cachedImage

            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async {
                
                self.image = image
                imageCachce.setObject(image, forKey: url as NSURL)
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { print("bad url"); return }
        downloadedFrom(url: url, contentMode: mode)
    }
}
