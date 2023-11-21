//
//  Club+CoreDataProperties.swift
//  CSCI 187 Project
//
//  Created by Jake Treska on 11/20/23.
//
//

import Foundation
import CoreData


extension Club {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Club> {
        return NSFetchRequest<Club>(entityName: "Club")
    }

    @NSManaged public var name: String?
    @NSManaged public var meeting_days: String?
    @NSManaged public var meeting_times: String?
    @NSManaged public var club_info: String?

}

extension Club : Identifiable {

}
