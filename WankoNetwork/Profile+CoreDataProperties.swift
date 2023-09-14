//
//  Profile+CoreDataProperties.swift
//  WankoNetwork
//
//  Created by satoshoco on 2023/09/10.
//
//

import Foundation
import CoreData


extension Profile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Profile> {
        return NSFetchRequest<Profile>(entityName: "Profile")
    }

    @NSManaged public var name: String?
    @NSManaged public var photo: Data?
    @NSManaged public var type: String?
    @NSManaged public var home: String?
    @NSManaged public var memo: String?
    @NSManaged public var age: Int16
    @NSManaged public var gender: String?

}

extension Profile : Identifiable {

}
