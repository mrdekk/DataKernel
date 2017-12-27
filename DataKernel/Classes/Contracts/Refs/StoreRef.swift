//
//  Store.swift
//  DataKernel
//
//  Created by Denis Malykh on 30/04/16.
//  Copyright © 2016 mrdekk. All rights reserved.
//

import Foundation

public enum StoreRef: Equatable {
    case url(URL)
    case named(String)
    case namedInGroup(name: String, appGroup: String)

    public func location() -> URL {
        switch self {
        case let .url(url):
            return url

        case let .named(name):
            return Foundation.URL(fileURLWithPath: FileUtils.documents()).appendingPathComponent(name)

        case let .namedInGroup(name, appGroup):
            let containerUrl = FileUtils.documents(in: appGroup)
            guard let dbDirUrl = containerUrl?.appendingPathComponent(dataKernelPath) else {
                assert(false)
                return StoreRef.named(name).location()
            }
            return dbDirUrl.appendingPathComponent(name)
        }
    }

    // NOTE: If we move the store from a local directory to a shared one, we'd like to know where to migrate it from
    func previousLocation() -> URL? {
        switch self {
        case let .namedInGroup(name, _):
            return StoreRef.named(name).location()
            
        default:
            return nil
        }
    }
}

public func == (lhs: StoreRef, rhs: StoreRef) -> Bool {
    return lhs.location() == rhs.location()
}

private let dataKernelPath = "DataKernel"
