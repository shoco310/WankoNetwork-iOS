//
//  Thumbnail+CoreDataProperties.swift
//  WankoNetwork
//
//  Created by satoshoco on 2023/09/08.
//
//

import Foundation
import CoreData


extension Thumbnail {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Thumbnail> {
        return NSFetchRequest<Thumbnail>(entityName: "Thumbnail")
    }

    @NSManaged public var photo: Date?
    @NSManaged public var comment: String?
    @NSManaged public var dog: Dog?

}

extension Thumbnail : Identifiable {

}
