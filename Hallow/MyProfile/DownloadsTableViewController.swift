//
//  DownloadsTableViewController.swift
//  Hallow
//
//  Created by Alex Jones on 8/18/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit

class DownloadsTableViewController: UITableViewController {

    var audioPathURLs: [String] = []
    
    // MARK: - Life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        audioPathURLs = Utilities.pullUpDownloads()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioPathURLs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "downloadsCell", for: indexPath) as! DownloadsTableViewCell
        cell.title.text = audioPathURLs[indexPath.row]
        return cell
    }
    
    // Delete rows
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let audioURL = audioPathURLs[indexPath.row]
            Utilities.deleteFile(path: audioURL)
            tableView.deleteRows(at: [indexPath], with: .left)
        }
    }

}
