//
//  ExtensionCollectionView.swift
//  Yo
//
//  Created by Muhammad Asher Azeem on 13/06/2021.
//

import UIKit

extension UICollectionView {
    /*
     * Register Collection Cell
     */
    func registerCollectionCell(name: String) {
        self.register(UINib(nibName: name, bundle: nil), forCellWithReuseIdentifier: name)
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
    }
    
}
