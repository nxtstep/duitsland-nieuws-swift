//
//  AnyWrapper.swift
//  DuitslandNieuws
//
//  Created by Arjan Duijzer on 28/02/2017.
//  Copyright © 2017 SuperSimple.io. All rights reserved.
//

/// Wrapper for swift classes, protocols and structs to pass into an ObjC method that takes AnyObject type e.g.
public class AnyWrapper<T> {
    public let value: T
    
    required public init(_ value: T) {
        self.value = value
    }
}

/// Wrapper for swift classes, protocols and structs that can be used to wrap around an (immutable) struct variable
public class AnyMutableWrapper<T> {
    public var value: T
    
    required public init(_ value: T) {
        self.value = value
    }
}
