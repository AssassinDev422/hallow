//
//  FullJourneyViewController.swift
//  Hallow
//
//  Created by Alex Jones on 8/13/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import RealmSwift

class FullJourneyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ShowDetailDelegate {
    
    @IBOutlet weak var nextUpButton: UIButton!
    
    var chapters: [Chapter] = []
    var categories = ["Dailies", "Praylists", "Challenges"]
    var user = User()
    var _nextPrayer: Prayer?
    var _nextChapter: Chapter?
    var completedSegue: Bool = false

    
    // MARK: - Life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            let realm = try Realm()
            guard let realmUser = realm.objects(User.self).first else {
                print("REALM: Error starting realm in full journey will appear")
                return
            }
            user = realmUser
            _nextPrayer = realm.objects(Prayer.self).filter("prayerIndex = %a", user.nextPrayerIndex).first
            guard let nextPrayer = _nextPrayer else {
                print("Error in full journey will appear")
                return
            }
            _nextChapter = realm.objects(Chapter.self).filter("index = %a", nextPrayer.chapterIndex).first
            guard let nextChapter = _nextChapter else {
                print("Error in full journey will appear")
                return
            }
            nextUpButton.setTitle("\(nextChapter.name) - \(nextPrayer.title)", for: .normal)
            
            if completedSegue {
                showDetail(chapterIndex: nextChapter.index)
            }
        } catch {
            print("REALM: Error in full journey will appear")
        }
    }
    
    // MARK: - Set up tableview
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return categories[section]
//    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
        returnedView.backgroundColor = .red
        
        let label = UILabel(frame: CGRect(x: 10, y: 7, width: view.frame.size.width, height: 25))
        label.text = self.categories[section]
        label.textColor = .green
        returnedView.addSubview(label)
        
        return returnedView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(25)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FullJourneyTableViewCell
        let section = indexPath.section
        do {
            let realm = try Realm()
            chapters = Array(realm.objects(Chapter.self).filter("categoryIndex = %a", section).sorted(byKeyPath: "index", ascending: true))
        } catch {
            print("REALM: Error in setting up collection views of full journey")
        }
        cell.tableViewSection = section
        cell.chapters = chapters
        cell.showDetailDelegate = self
        return cell
    }
    
    // MARK: - Actions
    
    @IBAction func nextUpButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "nextUpSegue", sender: _nextPrayer)
    }
    
    // MARK: - Navigation
    
    func showDetail(chapterIndex: Int) {
        print("Chapter Index in protocol segue function: \(chapterIndex)")
        performSegue(withIdentifier: "showDetailSegue", sender: chapterIndex)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PrayerJourneySuperViewController, let chapterIndex = sender as? Int {
            destination.chapterIndex = chapterIndex
        } else if let destination = segue.destination as? UITabBarController, let prayNow = destination.viewControllers?.first as? PrayNowViewController, let prayer = sender as? Prayer {
            prayNow.prayer = prayer
        }
    }
    
}

// MARK: - Protocols

protocol ShowDetailDelegate {
    func showDetail(chapterIndex: Int)
}
