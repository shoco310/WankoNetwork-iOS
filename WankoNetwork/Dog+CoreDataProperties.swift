//
//  Dog+CoreDataProperties.swift
//  WankoNetwork
//
//  Created by satoshoco on 2023/09/08.
//
//

import Foundation
import CoreData


extension Dog {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Dog> {
        return NSFetchRequest<Dog>(entityName: "Dog")
    }

    @NSManaged public var name: String?
    @NSManaged public var type: String?
    @NSManaged public var home: String?
    @NSManaged public var photo: Data?
    @NSManaged public var memo: String?
    @NSManaged public var thumbanails: NSSet?

}

// MARK: Generated accessors for thumbanails
extension Dog {

    @objc(addThumbanailsObject:)
    @NSManaged public func addToThumbanails(_ value: Thumbnail)

    @objc(removeThumbanailsObject:)
    @NSManaged public func removeFromThumbanails(_ value: Thumbnail)

    @objc(addThumbanails:)
    @NSManaged public func addToThumbanails(_ values: NSSet)

    @objc(removeThumbanails:)
    @NSManaged public func removeFromThumbanails(_ values: NSSet)

}

extension Dog : Identifiable {

}
