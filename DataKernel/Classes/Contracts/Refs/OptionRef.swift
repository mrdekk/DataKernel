//
//  OptionRef.swift
//  DataKernel
//
//  Created by Denis Malykh on 01/05/16.
//  Copyright © 2016 mrdekk. All rights reserved.
//

import Foundation
import CoreData

public enum OptionRef {
    case Default
    case Migration
    
    func build() -> [NSObject: AnyObject] {
        switch self {
        case .Default:
            var sqliteOptions: [String: String] = [String: String] ()
            sqliteOptions["WAL"] = "journal_mode"
            var options: [NSObject: AnyObject] = [NSObject: AnyObject] ()
            options[NSMigratePersistentStoresAutomaticallyOption] = NSNumber(bool: true)
            options[NSInferMappingModelAutomaticallyOption] = NSNumber(bool: false)
            options[NSSQLitePragmasOption] = sqliteOptions
            return options
        case .Migration:
            var sqliteOptions: [String: String] = [String: String] ()
            sqliteOptions["WAL"] = "journal_mode"
            var options: [NSObject: AnyObject] = [NSObject: AnyObject] ()
            options[NSMigratePersistentStoresAutomaticallyOption] = NSNumber(bool: true)
            options[NSInferMappingModelAutomaticallyOption] = NSNumber(bool: true)
            options[NSSQLitePragmasOption] = sqliteOptions
            return options
        }
    }

}