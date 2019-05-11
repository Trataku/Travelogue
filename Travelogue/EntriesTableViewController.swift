//
//  EntriesTableViewController.swift
//  Travelogue
//
//  Created by Dylan Mouser on 5/10/19.
//  Copyright © 2019 Dylan Mouser. All rights reserved.
//

import UIKit

class EntriesTableViewController: UITableViewController {

    @IBOutlet var EntryTableView: UITableView!
    
    var trip: Trip?
    var entries = [Entry]()
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = trip?.title ?? ""
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateEntriesArray()
        EntryTableView.reloadData()
    }
    
    func updateEntriesArray() {
        entries = trip?.entries?.sortedArray(using: [NSSortDescriptor(key: "title", ascending: true)]) as? [Entry] ?? [Entry]()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func alertNotifyUser(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteEntry(at indexPath: IndexPath) {
        let entry = entries[indexPath.row]
        
        if let managedObjectContext = entry.managedObjectContext {
            managedObjectContext.delete(entry)
            
            do {
                try managedObjectContext.save()
                self.entries.remove(at: indexPath.row)
                EntryTableView.deleteRows(at: [indexPath], with: .automatic)
            } catch {
                alertNotifyUser(message: "Delete failed.")
                EntryTableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TravelCell", for: indexPath)
        
        let entry = entries[indexPath.row]
        cell.textLabel?.text = entry.title
        if let addDate = entry.addDate {
            cell.detailTextLabel?.text = dateFormatter.string(from: addDate)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") {
            action, index in
            self.deleteEntry(at: indexPath)
        }
        
        return [delete]
    }
    
    func deleteEntry(indexPath: IndexPath) {
        let entry = entries[indexPath.row]
        
        if let managedObjectContext = entry.managedObjectContext {
            managedObjectContext.delete(entry)
            
            do {
                try managedObjectContext.save()
                self.entries.remove(at: indexPath.row)
                EntryTableView.reloadData()
            } catch {
                alertNotifyUser(message: "Delete failed.")
                EntryTableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return entries.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? EntryViewController,
            let segueIdentifier = segue.identifier {
            destination.trip = trip
            if (segueIdentifier == "existingEntry") {
                if let row = EntryTableView.indexPathForSelectedRow?.row {
                    destination.entry = entries[row]
                }
            }
        }
    }
    
    

}
