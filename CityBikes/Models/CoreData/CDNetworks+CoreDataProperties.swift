//
//  CDNetworks+CoreDataProperties.swift
//  CityBikes
//
//  Created by Sigurd Paul Mayer on 2/7/21.
//
//

import Foundation
import CoreData


extension CDNetworks {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDNetworks> {
        return NSFetchRequest<CDNetworks>(entityName: "CDNetworks")
    }

    @NSManaged public var href: String?
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var location: CDLocation?

}

//extension CDNetworks : Identifiable {
//
//}
