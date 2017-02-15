//
//  NSManagedObject.swift
//  DataKernel
//
//  Created by Denis Malykh on 02/05/16.
//  Copyright © 2016 mrdekk. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject: Entity {
    
    public class var entityName: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
}
