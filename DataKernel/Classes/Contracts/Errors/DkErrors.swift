//
//  DkErrors.swift
//  DataKernel
//
//  Created by Denis Malykh on 01/05/16.
//  Copyright © 2016 mrdekk. All rights reserved.
//

import Foundation

public enum DkErrors: ErrorType {
    case PersistentStoreInitilization // some errors during initialization of Core Data stack
    case RecursiveSaveFailed // some errors in recursive save of dependent NSManagedObjectContexts
    case InvalidEntityClass // class supplied to NSManagaedObjectContext as Context methods
}