//
//  Store.swift
//  DataKernel
//
//  Created by Denis Malykh on 30/04/16.
//  Copyright © 2016 mrdekk. All rights reserved.
//

import Foundation

public enum StoreRef: Equatable {
    case Named(String)
    case URL(NSURL)
    
    public func location() -> NSURL {
        switch self {
        case .URL(let url): return url
        case .Named(let name): return NSURL(fileURLWithPath: FileUtils.documents()).URLByAppendingPathComponent(name)
        }
    }    
}

public func == (lhs: StoreRef, rhs: StoreRef) -> Bool {
    return lhs.location() == rhs.location()
}
