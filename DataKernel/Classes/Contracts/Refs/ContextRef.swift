//
//  ContextRef.swift
//  DataKernel
//
//  Created by Denis Malykh on 01/05/16.
//  Copyright © 2016 mrdekk. All rights reserved.
//

import Foundation
import CoreData

public enum ContextRef {
    case coordinator(NSPersistentStoreCoordinator)
    case context(NSManagedObjectContext)
}
