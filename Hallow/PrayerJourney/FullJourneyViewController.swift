//
//  FullJourneyViewController.swift
//  Hallow
//
//  Created by Alex Jones on 8/13/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import RealmSwift

class FullJourneyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var nextUpLabel: UILabel!
    
    var chapters: [Chapter] = []
    var categories = ["Dailies", "Praylists", "Challenges"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categories[section]
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
        return cell
    }
    
}
