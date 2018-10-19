//
//  Article+CoreDataClass.swift
//  dvdovenk2018
//
//  Created by Danil Vdovenko on 10/12/18.
//
//

import Foundation
import CoreData


public class Article: NSManagedObject {
    
    override public var description: String {
        return "(Title: \(title ?? "Unknown"), Content: \(content ?? "Unknown"), Language: \(language ?? "Unknown"))"
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Article> {
        return NSFetchRequest<Article>(entityName: "Article")
    }
    
    @NSManaged public var title: String?
    @NSManaged public var content: String?
    @NSManaged public var language: String?
    @NSManaged public var image: NSData?
    @NSManaged public var creationDate: NSDate?
    @NSManaged public var modificationDate: NSDate?
    
}
