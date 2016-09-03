//
//  Context.swift
//  DataKernel
//
//  Created by Denis Malykh on 30/04/16.
//  Copyright © 2016 mrdekk. All rights reserved.
//

import Foundation

public protocol Context {
    func fetch<E: Entity>(request: DataRequest<E>) throws -> [E]
    func count<E: Entity>(request: DataRequest<E>) throws -> Int
    
    func create<E: Entity>() throws -> E
    func acquire<E: Entity>(value: AnyObject) throws -> E // if exist object that satisfies condition or result of create operation
    
    func remove<E: Entity>(entity: E) throws
    func remove<E: Entity>(entities: [E]) throws
    func remove<E: Entity>(condition: DataRequest<E>) throws // removes all entities that satisfies condition
    
    func wipe<E: Entity>(type: E.Type) throws // remove all entities
}