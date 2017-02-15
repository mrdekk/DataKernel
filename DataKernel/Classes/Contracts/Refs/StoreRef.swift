//
//  Store.swift
//  DataKernel
//
//  Created by Denis Malykh on 30/04/16.
//  Copyright © 2016 mrdekk. All rights reserved.
//

import Foundation

public enum StoreRef: Equatable {
    case named(String)
    case url(URL)
    
    public func location() -> URL {
        switch self {
        case .url(let url): return url
        case .named(let name): return Foundation.URL(fileURLWithPath: FileUtils.documents()).appendingPathComponent(name)
        }
    }    
}

public func == (lhs: StoreRef, rhs: StoreRef) -> Bool {
    return lhs.location() == rhs.location()
}
