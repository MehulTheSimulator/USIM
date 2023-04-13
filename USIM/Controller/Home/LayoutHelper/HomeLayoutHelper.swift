//
//  HomeViewHelper.swift
//  USIM
//
//  Created by Asher Azeem on 2/19/23.
//

import UIKit

class HomeLayoutHelper {
    
    var compositionLayoutHelper = CompositionalLayoutHelper()
    
    public lazy var tagSection: NSCollectionLayoutSection? = {
        let item = compositionLayoutHelper.makeItems(width: .estimated(100), height: .fractionalHeight(1.0))
        let group = compositionLayoutHelper.makeHorizontalGroup(width: .estimated(150), height: .estimated(60), with: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 0, trailing: 12)
        let section = compositionLayoutHelper.makeSection(with: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0)
        return section
    }()
    
}
