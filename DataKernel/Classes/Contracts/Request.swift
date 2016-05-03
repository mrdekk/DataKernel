//
//  Request.swift
//  DataKernel
//
//  Created by Denis Malykh on 30/04/16.
//  Copyright © 2016 mrdekk. All rights reserved.
//

import Foundation

public struct Request<E: Entity> {
    
    // MARK: - Props
    
    public let sort: NSSortDescriptor?
    public let predicate: NSPredicate?
    
    // MARK: - Init
    
    public init(sort: NSSortDescriptor? = nil, predicate: NSPredicate? = nil) {
        self.sort = sort
        self.predicate = predicate
    }
    
    
    // MARK: - Chaining specification methods
    
    public func filter(key: String, equalTo value: String) -> Request<E> {
        return self.redef(predicate: NSPredicate(format: "\(key) == %@", value))
    }
    
    public func filter(key: String, oneOf value: [String]) -> Request<E> {
        return self.redef(predicate: NSPredicate(format: "\(key) IN %@", value))
    }
    
    public func sort(key: String?, ascending: Bool) -> Request<E> {
        return self.redef(sort: NSSortDescriptor(key: key, ascending: ascending))
    }
    
    public func sort(key: String?, ascending: Bool, comparator cmptr: NSComparator) -> Request<E> {
        return self.redef(sort: NSSortDescriptor(key: key, ascending: ascending, comparator: cmptr))
    }
    
    public func sort(key: String?, ascending: Bool, selector: Selector) -> Request<E> {
        return self.redef(sort: NSSortDescriptor(key: key, ascending: ascending, selector: selector))
    }
    
    // MARK: - Internal
    
    func redef(predicate predicate: NSPredicate) -> Request<E> {
        return Request<E>(sort: self.sort, predicate: predicate)
    }
    
    func redef(sort sort: NSSortDescriptor) -> Request<E> {
        return Request<E>(sort: sort, predicate: self.predicate)
    }
    

}