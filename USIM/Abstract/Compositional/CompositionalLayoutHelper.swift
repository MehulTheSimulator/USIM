//
//  CompositionalLayoutHelper.swift
//  USIM
//
//  Created by Asher Azeem on 2/19/23.
//

import UIKit

class CompositionalLayoutHelper {
    
    // make Item with dimenstion
    func makeItems(width wSize: NSCollectionLayoutDimension, height hSize: NSCollectionLayoutDimension) -> NSCollectionLayoutItem {
        let itemSize = NSCollectionLayoutSize(widthDimension: wSize, heightDimension: hSize)
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        return item
    }
    
    // make Horizontal Group
    func makeHorizontalGroup(width wSize: NSCollectionLayoutDimension, height hSize: NSCollectionLayoutDimension, with items: [NSCollectionLayoutItem]) -> NSCollectionLayoutGroup {
        let groupSize = NSCollectionLayoutSize(widthDimension: wSize, heightDimension: hSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: items)
        return group
    }
    
    // make section With / without header
    func makeSection(with group: NSCollectionLayoutGroup) -> NSCollectionLayoutSection {
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
}
