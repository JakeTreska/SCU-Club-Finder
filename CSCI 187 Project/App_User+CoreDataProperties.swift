//
//  App_User+CoreDataProperties.swift
//  CSCI 187 Project
//
//  Created by Jake Treska on 11/29/23.
//
//

import Foundation
import CoreData


extension App_User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<App_User> {
        return NSFetchRequest<App_User>(entityName: "App_User")
    }

    @NSManaged public var user_email: String?
    @NSManaged public var user_major: String?
    @NSManaged public var user_name: String?
    @NSManaged public var user_year: String?
    @NSManaged public var user_list_clubs: String?

}

extension App_User : Identifiable {

}
