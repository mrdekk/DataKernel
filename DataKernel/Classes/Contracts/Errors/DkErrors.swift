//
//  DkErrors.swift
//  DataKernel
//
//  Created by Denis Malykh on 01/05/16.
//  Copyright © 2016 mrdekk. All rights reserved.
//

import Foundation

public enum DkErrors: Error {
    case persistentStoreInitilization // some errors during initialization of Core Data stack
    case recursiveSaveFailed // some errors in recursive save of dependent NSManagedObjectContexts
    case invalidEntityClass // class supplied to NSManagaedObjectContext as Context methods
}
