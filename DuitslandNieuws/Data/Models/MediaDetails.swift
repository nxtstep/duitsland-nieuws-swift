//
// Created by Arjan Duijzer on 08/03/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import Foundation
import ObjectMapper

struct MediaDetails {
    let width: Int
    let height: Int
    let file: String
    let sizes: [String: MediaItem]
}

/// Mapping from JSON with ObjectMapper

extension MediaDetails: ImmutableMappable {

    init(map: Map) throws {
        width = try map.value("width")
        height = try map.value("height")
        file = try map.value("file")
        sizes = try map.value("sizes")
    }
}