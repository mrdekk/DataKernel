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
    case Named(String, NSBundle)
    case Merged([NSBundle]?)
    case URL(NSURL)
    
    func build() -> NSManagedObjectModel? {
        switch self {
        case .Named(let name, let bundle):
            return NSManagedObjectModel(contentsOfURL: bundle.URLForResource(name, withExtension: "momd")!)
        case .Merged(let bundles):
            return NSManagedObjectModel.mergedModelFromBundles(bundles)
        case .URL(let url):
            return NSManagedObjectModel(contentsOfURL: url)
        }
        
    }

}