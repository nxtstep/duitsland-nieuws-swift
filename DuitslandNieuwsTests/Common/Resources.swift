//
// Created by Arjan Duijzer on 06/03/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import Foundation

/// Create file path for a given Type to load in a test environment
public func testResourcePath(for klass: AnyObject.Type, name file: String) -> String {
    let bundle = Bundle(for: klass)
    let bundlePath = bundle.bundlePath
    let resourceFilePath = "file://\(bundlePath)/test.bundle/\(file)"

    return resourceFilePath
}

public extension String {
    public var sampleData: Data {
        let file = URL(string:self)!
        return try! Data(contentsOf: file)
    }
}