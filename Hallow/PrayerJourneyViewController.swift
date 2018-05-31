//
//  PrayerJourneyViewController.swift
//  Hallow
//
//  Created by Alex Jones on 5/13/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import Firebase

//TODO: change to an exit segue

class PrayerJourneyViewController: UICollectionViewController {

    var prayers: [PrayerItem] = []
    var completedPrayers: [PrayerTracking] = []
    
    private let reuseIdentifier = "cell"
    
    var handle: AuthStateDidChangeListenerHandle?
    var userID: String?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAllPrayers()
    }
    
    // Firebase listener
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.userID = user!.uid
            self.loadCompletedPrayers()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    
    // MARK: - Functions
    
    private func loadAllPrayers() {
        FirebaseUtilities.loadAllDocumentsByGuideStandardLength(ofType: "prayer", byGuide: Constants.guide) { results in
            self.prayers = results.map(PrayerItem.init)
            self.prayers.sort{$0.title < $1.title}
            print("Prayer guide: \(Constants.guide)")
            print("Prayer sessions: \(self.prayers.count)")
            self.collectionView!.reloadData()
        }
    }
    
    private func loadCompletedPrayers() {
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "completedPrayers", byUser: self.userID!) {results in
            self.completedPrayers = results.map(PrayerTracking.init)
            print("Completed prayers: \(self.completedPrayers.count)")
            self.collectionView!.reloadData()
        }
    }

    // MARK: - UICollectionViewDataSource and set up

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Prayer sessions: \(prayers.count)")
        return prayers.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PrayerJourneyCollectionViewCell
        let prayer = prayers[indexPath.row]
        cell.prayerCellTitle.text = prayer.title
        cell.prayerCellDescription.text = prayer.description
        
        let completed = self.completedPrayers.contains {$0.title == prayer.title}
        if completed == true {
            cell.layer.backgroundColor = UIColor.lightGray.cgColor
            cell.layer.borderColor = UIColor.darkGray.cgColor
            cell.prayerCellTitle.textColor = UIColor.darkGray
            cell.prayerCellDescription.textColor = UIColor.darkGray
        } else {
            cell.layer.backgroundColor = UIColor.clear.cgColor
            cell.layer.borderColor = UIColor.black.cgColor
            cell.prayerCellTitle.textColor = UIColor.black
            cell.prayerCellDescription.textColor = UIColor.black
        }
        
        cell.layer.borderWidth = 1
        
        return cell
    }

    // MARK: - UICollectionViewDelegate and appearance
    
    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.lightGray
    }
    
    override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.clear
    }
    
    // MARK: - Navigation
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let prayer = prayers[indexPath.item]
        performSegue(withIdentifier: "returnToPrayNowSegue", sender: prayer)
        print("Prayer title from collection view: \(prayer.title)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UITabBarController, let nav = destination.viewControllers?.first as? UINavigationController, let prayNow = nav.topViewController as? PrayNowViewController, let prayer = sender as? PrayerItem {
                prayNow.prayer = prayer
        }
    }
}
