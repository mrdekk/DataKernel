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
    case `default`
    case migration
    
    func build() -> [AnyHashable: Any] {
        switch self {
        case .default:
            var sqliteOptions: [String: String] = [String: String] ()
            sqliteOptions["WAL"] = "journal_mode"
            var options: [AnyHashable: Any] = [AnyHashable: Any] ()
            options[NSMigratePersistentStoresAutomaticallyOption] = NSNumber(value: true as Bool)
            options[NSInferMappingModelAutomaticallyOption] = NSNumber(value: false as Bool)
            options[NSSQLitePragmasOption] = sqliteOptions
            return options
        case .migration:
            var sqliteOptions: [String: String] = [String: String] ()
            sqliteOptions["WAL"] = "journal_mode"
            var options: [AnyHashable: Any] = [AnyHashable: Any] ()
            options[NSMigratePersistentStoresAutomaticallyOption] = NSNumber(value: true as Bool)
            options[NSInferMappingModelAutomaticallyOption] = NSNumber(value: true as Bool)
            options[NSSQLitePragmasOption] = sqliteOptions
            return options
        }
    }

}
