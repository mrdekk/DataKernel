//
//  ModelRef.swift
//  DataKernel
//
//  Created by Denis Malykh on 30/04/16.
//  Copyright © 2016 mrdekk. All rights reserved.
//

import Foundation
import CoreData

public enum ModelRef {
    case named(String, Bundle)
    case merged([Bundle]?)
    case url(Foundation.URL)
    
    func build() -> NSManagedObjectModel? {
        switch self {
        case .named(let name, let bundle):
            return NSManagedObjectModel(contentsOf: bundle.url(forResource: name, withExtension: "momd")!)
        case .merged(let bundles):
            return NSManagedObjectModel.mergedModel(from: bundles)
        case .url(let url):
            return NSManagedObjectModel(contentsOf: url)
        }
        
    }

}
