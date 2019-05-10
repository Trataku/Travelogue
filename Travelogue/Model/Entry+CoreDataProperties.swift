//
//  Entry+CoreDataProperties.swift
//  Travelogue
//
//  Created by Dylan Mouser on 5/10/19.
//  Copyright © 2019 Dylan Mouser. All rights reserved.
//
//

import Foundation
import CoreData


extension Entry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entry> {
        return NSFetchRequest<Entry>(entityName: "Entry")
    }

    @NSManaged public var title: String?
    @NSManaged public var body: String?
    @NSManaged public var rawAddDate: NSDate?
    @NSManaged public var rawImage: NSData?
    @NSManaged public var trip: Trip?

}
