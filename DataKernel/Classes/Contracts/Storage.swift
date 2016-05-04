//
//  Storage.swift
//  DataKernel
//
//  Created by Denis Malykh on 30/04/16.
//  Copyright © 2016 mrdekk. All rights reserved.
//

import Foundation

public protocol Storage {
    var uiContext: Context! { get }
    
    func perform(ephemeral: Bool, unitOfWork: (context: Context, save: () -> Void) throws -> Void) throws
    func performAsync(ephemeral: Bool, unitOfWork: (context: Context, save: () -> Void) throws -> Void) throws
    
    func wipeStore() throws // removes store from coordinator and removes store file, to restore store use restoreStore()
    func restoreStore() throws
}