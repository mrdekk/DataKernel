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
    
    public func filter(_ key: String, equalTo value: Any) -> Request<E> {
        return self.redef(predicate: NSPredicate(format: "\(key) == %@", argumentArray: [value]))
    }
    
    public func filter(_ key: String, oneOf value: [Any]) -> Request<E> {
        return self.redef(predicate: NSPredicate(format: "\(key) IN %@", argumentArray: [value]))
    }
    
    public func sort(_ key: String?, ascending: Bool) -> Request<E> {
        return self.redef(sort: NSSortDescriptor(key: key, ascending: ascending))
    }
    
    public func sort(_ key: String?, ascending: Bool, comparator cmptr: @escaping Comparator) -> Request<E> {
        return self.redef(sort: NSSortDescriptor(key: key, ascending: ascending, comparator: cmptr))
    }
    
    public func sort(_ key: String?, ascending: Bool, selector: Selector) -> Request<E> {
        return self.redef(sort: NSSortDescriptor(key: key, ascending: ascending, selector: selector))
    }
    
    // MARK: - Internal
    
    func redef(predicate: NSPredicate) -> Request<E> {
        return Request<E>(sort: self.sort, predicate: predicate)
    }
    
    func redef(sort: NSSortDescriptor) -> Request<E> {
        return Request<E>(sort: sort, predicate: self.predicate)
    }
    

}
