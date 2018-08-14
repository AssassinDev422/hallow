//
//  FullJourneyTableViewCell.swift
//  Hallow
//
//  Created by Alex Jones on 8/13/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import RealmSwift

class FullJourneyTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var tableViewSection: Int = 0
    var chapters: [Chapter] = []
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chapterCell", for: indexPath) as! FullJourneyCollectionViewCell
        print("Index Path: \(indexPath)")
        
        let chapter = chapters[indexPath.row]
        cell.mainLabel.text = chapter.name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return chapters.count
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let chaptersPerRow: CGFloat = 3
        let padding: CGFloat = 10
        let chapterWidth = (collectionView.bounds.width / chaptersPerRow) - padding
        let chapterHeight = collectionView.bounds.height - (2 * padding)
        return CGSize(width: chapterWidth, height: chapterHeight)
    }

}
