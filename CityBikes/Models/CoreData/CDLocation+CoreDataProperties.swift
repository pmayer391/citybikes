//
//  CDLocation+CoreDataProperties.swift
//  CityBikes
//
//  Created by Sigurd Paul Mayer on 2/6/21.
//
//

import Foundation
import CoreData


extension CDLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDLocation> {
        return NSFetchRequest<CDLocation>(entityName: "CDLocation")
    }

    @NSManaged public var city: String?
    @NSManaged public var country: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double

}

//extension CDLocation : Identifiable {
//
//}
