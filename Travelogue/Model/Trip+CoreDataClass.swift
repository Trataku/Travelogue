//
//  Trip+CoreDataClass.swift
//  Travelogue
//
//  Created by Dylan Mouser on 5/10/19.
//  Copyright © 2019 Dylan Mouser. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

@objc(Trip)
public class Trip: NSManagedObject {

    convenience init?(name: String?) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard let managedContext = appDelegate?.persistentContainer.viewContext,
            let name = name, name != "" else {
                return nil
        }
        self.init(entity: Trip.entity(), insertInto: managedContext)
        self.title = name
    }
}
