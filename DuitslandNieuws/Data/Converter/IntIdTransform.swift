//
// Created by Arjan Duijzer on 06/03/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import Foundation
import ObjectMapper

class IntIdTransform : TransformType {
    public typealias Object = String
    public typealias JSON = Int

    public init() {}

    func transformFromJSON(_ value: Any?) -> String? {
        guard let key = value as? Int else {
            return nil
        }
        return String(key)
    }

    func transformToJSON(_ value: String?) -> Int? {
        return value.flatMap {
            Int($0)
        }
    }
}
