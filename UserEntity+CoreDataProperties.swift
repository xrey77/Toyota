//
//  UserEntity+CoreDataProperties.swift
//  Toyota
//
//  Created by Reynald Marquez-Gragasin on 5/26/25.
//
//

import Foundation
import CoreData


extension UserEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }

    @NSManaged public var updatedAt: Date?
    @NSManaged public var createdAt: Date?
    @NSManaged public var password: String?
    @NSManaged public var username: String?
    @NSManaged public var mobileno: String?
    @NSManaged public var emailadd: String?
    @NSManaged public var lastname: String?
    @NSManaged public var firstname: String?
    @NSManaged public var userid: String?

}

extension UserEntity : Identifiable {

}
