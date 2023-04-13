//
//  UIImage.swift
//  USIM
//
//  Created by Asher Azeem on 05/03/2023.
//

import UIKit

extension UIImageView {
    func loadGifFile(with: String) {
        guard let main = Bundle.main.url(forResource: with, withExtension: "gif") else {
            fatalError("No icon available")
        }
        let imageData = try? Data(contentsOf: main)
        let loadedImage = UIImage.sd_image(withGIFData: imageData)
        image = loadedImage
    }
}
