//
//  ReachabilityManager.swift
//  Hallow
//
//  Created by Alex Jones on 6/27/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import Reachability

/// Protocol for listenig network status change
public protocol NetworkStatusListener : class {
    func networkStatusDidChange(status: Reachability.Connection)
}

class ReachabilityManager: NSObject {
    
    static  let shared = ReachabilityManager()
    
    // 3. Boolean to track network reachability
    var isNetworkAvailable : Bool {
        return reachabilityStatus != .none
    }
    
    // 4. Tracks current NetworkStatus (none, wifi, cellular)
    var reachabilityStatus: Reachability.Connection = .none
    
    // 5. Reachability instance for Network status monitoring
    let reachability = Reachability()!
    
    // 6. Array of delegates which are interested to listen to network status change
    var listeners = [NetworkStatusListener]()
    
    /// Called whenever there is a change in NetworkReachibility Status
    /// — parameter notification: Notification with the Reachability instance
    @objc func reachabilityChanged(notification: Notification) {
        let reachability = notification.object as! Reachability
        
        switch reachability.connection {
            case .none:
                print("===========>Network became unreachable")
            case .wifi:
                print("===========>Network reachable through WiFi")
            case .cellular:
                print("===========>Network reachable through Cellular Data")
        }
        
        // Sending message to each of the delegates
        for listener in listeners {
            listener.networkStatusDidChange(status: reachability.connection)
        }
    }
    
    /// Starts monitoring the network availability status
    func startMonitoring() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.reachabilityChanged),
                                               name: Notification.Name.reachabilityChanged,
                                               object: reachability)
        do{
            try reachability.startNotifier()
        } catch {
            print("Could not start reachability notifier")
        }
    }
    
    /// Stops monitoring the network availability status
    func stopMonitoring(){
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name.reachabilityChanged,
                                                  object: reachability)
    }
    
    /// Adds a new listener to the listeners array
    ///
    /// - parameter delegate: a new listener
    func addListener(listener: NetworkStatusListener){
        listeners.append(listener)
    }
    
    /// Removes a listener from listeners array
    ///
    /// - parameter delegate: the listener which is to be removed
    func removeListener(listener: NetworkStatusListener){
        listeners = listeners.filter{ $0 !== listener}
    }

}

extension UIViewController: NetworkStatusListener {
    
    public func networkStatusDidChange(status: Reachability.Connection) {
        
        switch status {
        case .none:
            print("ViewController: Network became unreachable")
            let alert = UIAlertController(title: "No internet connection", message: "Without connection the app will lose significant functionality, tracking and is likely to crash", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
        case .wifi:
            print("ViewController: Network reachable through WiFi")
        case .cellular:
            print("ViewController: Network reachable through Cellular Data")
        }
    }
}
