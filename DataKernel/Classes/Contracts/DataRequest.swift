//
//  Request.swift
//  DataKernel
//
//  Created by Denis Malykh on 30/04/16.
//  Copyright © 2016 mrdekk. All rights reserved.
//

import Foundation

public struct DataRequest<E: Entity> {
    
    // MARK: - Props
    
    public let sort: NSSortDescriptor?
    public let predicate: NSPredicate?
    
    // MARK: - Init
    
    public init(sort: NSSortDescriptor? = nil, predicate: NSPredicate? = nil) {
        self.sort = sort
        self.predicate = predicate
    }
    
    
    // MARK: - Chaining specification methods
    
    public func filter(key: String, equalTo value: AnyObject) -> DataRequest<E> {
        return self.redef(predicate: NSPredicate(format: "\(key) == %@", argumentArray: [value]))
    }
    
    public func filter(key: String, oneOf value: [AnyObject]) -> DataRequest<E> {
        return self.redef(predicate: NSPredicate(format: "\(key) IN %@", argumentArray: [value]))
    }
    
    public func sort(key: String?, ascending: Bool) -> DataRequest<E> {
        return self.redef(sort: NSSortDescriptor(key: key, ascending: ascending))
    }
    
    public func sort(key: String?, ascending: Bool, comparator cmptr: NSComparator) -> DataRequest<E> {
        return self.redef(sort: NSSortDescriptor(key: key, ascending: ascending, comparator: cmptr))
    }
    
    public func sort(key: String?, ascending: Bool, selector: Selector) -> DataRequest<E> {
        return self.redef(sort: NSSortDescriptor(key: key, ascending: ascending, selector: selector))
    }
    
    // MARK: - Internal
    
    func redef(predicate predicate: NSPredicate) -> DataRequest<E> {
        return DataRequest<E>(sort: self.sort, predicate: predicate)
    }
    
    func redef(sort sort: NSSortDescriptor) -> DataRequest<E> {
        return DataRequest<E>(sort: sort, predicate: self.predicate)
    }
    

}