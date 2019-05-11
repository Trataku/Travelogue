//
//  TripTableViewController.swift
//  Travelogue
//
//  Created by Dylan Mouser on 5/7/19.
//  Copyright © 2019 Dylan Mouser. All rights reserved.
//

import UIKit
import CoreData

class TripTableViewController: UITableViewController {
    
    var trips = [Trip]()
    var dateFormatter = DateFormatter()
    
    @IBOutlet var TripTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchTrips(searchString: "")
    }
    
    @IBAction func add(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add Trip", message: "Enter new trip name.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Submit", style: UIAlertAction.Style.default, handler: {
            (alertAction) -> Void in
            if let textField = alert.textFields?[0], let name = textField.text {
                let tripTitle = name.trimmingCharacters(in: .whitespaces)
                if (tripTitle == "") {
                    self.alertNotifyUser(message: "Trip not created.\nThe name must contain a value.")
                    return
                }
                self.addTrip(name: tripTitle)
            } else {
                self.alertNotifyUser(message: "Trip not created.\nThe name is not accessible.")
                return
            }
            
        }))
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "trip name"
            textField.isSecureTextEntry = false
            
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func addTrip(name: String) {
        // check if category by that name already exists
        if (tripExists(name: name)) {
            alertNotifyUser(message: "Trip \(name) already exists.")
            return
        }
        
        let trip = Trip(name: name)
        
        if let trip = trip {
            do {
                let managedObjectContext = trip.managedObjectContext
                try managedObjectContext?.save()
            } catch {
                print("Trip could not be saved.")
            }
        } else {
            print("Trip could not be created.")
        }
        
        fetchTrips(searchString: "")
    }
    
    func confirmDeleteTrip(at indexPath: IndexPath) {
        let trip = trips[indexPath.row]
        
        if let entrySet = trip.entries, entrySet.count > 0 {
            // confirm deletion
            let name = trip.title ?? "Trip"
            let alert = UIAlertController(title: "Delete Trip", message: "\(name) contains entries. Do you want to delete it?", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {
                (alertAction) -> Void in
                // handle cancellation of deletion
                self.TripTableView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive, handler: {
                (alertAction) -> Void in
                // handle deletion here
                self.deleteTrip(at: indexPath)
            }))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            deleteTrip(at: indexPath)
        }
    }
    
    
    func deleteTrip(at indexPath: IndexPath) {
        let trip = trips[indexPath.row]
        
        if let managedObjectContext = trip.managedObjectContext {
            managedObjectContext.delete(trip)
            
            do {
                try managedObjectContext.save()
                self.trips.remove(at: indexPath.row)
                TripTableView.deleteRows(at: [indexPath], with: .automatic)
            } catch {
                print("Delete failed: \(error).")
                TripTableView.reloadData()
            }
        }
    }
    
    func alertNotifyUser(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func edit(at indexPath: IndexPath) {
        let trip = trips[indexPath.row]
        let alert = UIAlertController(title: "Edit Trip", message: "Enter new trip name.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Submit", style: UIAlertAction.Style.default, handler: {
            (alertAction) -> Void in
            if let textField = alert.textFields?[0], let title = textField.text {
                let tripTitle = title.trimmingCharacters(in: .whitespaces)
                if (tripTitle == "") {
                    self.alertNotifyUser(message: "Trip name not changed.\nA name is required.")
                    return
                }
                
                if (tripTitle == trip.title) {
                    // Nothing to change, new name is old name.
                    // Do this check before checking that categoryExists,
                    // otherwise if category name doesn't change error about already existing will occur.
                    return
                }
                
                if (self.tripExists(name: tripTitle)) {
                    self.alertNotifyUser(message: "Trip name not changed.\n\(tripTitle) already exists.")
                    return
                }
                
                self.updateTrip(at: indexPath, name: tripTitle)
            } else {
                self.alertNotifyUser(message: "Trip name not changed.\nThe name is not accessible.")
                return
            }
            
        }))
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "trip name"
            textField.isSecureTextEntry = false
            textField.text = trip.title
            
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func tripExists(name: String) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, name != "" else {
            return false
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Trip> = Trip.fetchRequest()
        do {
            fetchRequest.predicate = NSPredicate(format: "title == %@", name)
            let results = try managedContext.fetch(fetchRequest)
            if results.count > 0 {
                return true
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    func fetchTrips(searchString: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Trip> = Trip.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        do {
            if (searchString != "") {
                fetchRequest.predicate = NSPredicate(format: "title contains[c] %@", searchString)
            }
            trips = try managedContext.fetch(fetchRequest)
            TripTableView.reloadData()
        } catch {
            print("Fetch could not be performed")
        }
    }
    
    func updateTrip(at indexPath: IndexPath, name: String) {
        let trip = trips[indexPath.row]
        trip.title = name
        
        if let managedObjectContext = trip.managedObjectContext {
            do {
                try managedObjectContext.save()
                fetchTrips(searchString: "")
            } catch {
                print("Update failed.")
                TripTableView.reloadData()
            }
        }
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return trips.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath)
        
        let trip = trips[indexPath.row]
        cell.textLabel?.text = trip.title
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") {
            action, index in
            self.confirmDeleteTrip(at: indexPath)
        }
        
        let edit = UITableViewRowAction(style: .default, title: "Edit") {
            action, index in
            self.edit(at: indexPath)
        }
        edit.backgroundColor = UIColor.blue
        
        return [delete, edit]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? EntriesTableViewController,
            let row = TripTableView.indexPathForSelectedRow?.row {
            destination.trip = trips[row]
        }
    }

}
