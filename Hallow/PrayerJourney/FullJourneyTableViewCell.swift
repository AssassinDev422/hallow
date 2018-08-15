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
    var showDetailDelegate: ShowDetailDelegate? = nil
    
    // MARK: - Set up collectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chapters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chapterCell", for: indexPath) as! FullJourneyCollectionViewCell
        let chapter = chapters[indexPath.row]
        cell.mainLabel.text = chapter.name
        if chapter.avail {
            cell.backgroundColor = UIColor(named: "deepLilac")
            cell.mainLabel.textColor = UIColor(named: "beige")
        } else {
            cell.backgroundColor = UIColor(named: "beige")
            cell.mainLabel.textColor = UIColor(named: "fadedPink")
        }
        return cell
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let chaptersPerRow: CGFloat = 3
//        let padding: CGFloat = 10
//        let chapterWidth = (collectionView.bounds.width / chaptersPerRow) - padding
//        let chapterHeight = collectionView.bounds.height - (2 * padding)
        return CGSize(width: 95, height: 114)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let chapter = chapters[indexPath.row]
        print("In collection view chapterIndex: \(chapter.index), chapterName: \(chapter.name)")
        if chapter.avail {
            showDetailDelegate?.showDetail(chapterIndex: chapter.index)
        } else {
            print("Chapter not avail")
        }
    }

}
