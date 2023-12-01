//
//  Club+CoreDataProperties.swift
//  CSCI 187 Project
//
//  Created by Jake Treska on 11/28/23.
//
//

import Foundation
import CoreData


extension Club {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Club> {
        return NSFetchRequest<Club>(entityName: "Club")
    }

    @NSManaged public var club_category: String?
    @NSManaged public var club_info: String?
    @NSManaged public var contact_information: String?
    @NSManaged public var name: String?
    @NSManaged public var requirements: String?

}

extension Club : Identifiable {

}
