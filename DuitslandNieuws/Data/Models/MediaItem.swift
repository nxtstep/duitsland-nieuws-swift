//
// Created by Arjan Duijzer on 08/03/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import Foundation
import ObjectMapper

struct MediaItem {
    let file: String
    let width: Int
    let height: Int
    let mimeType: String
    let sourceUrl: String
}

/// Mapping from JSON with ObjectMapper

extension MediaItem: ImmutableMappable {
    
    init(map: Map) throws {
        width = try map.value("width")
        height = try map.value("height")
        file = try map.value("file")
        mimeType = try map.value("mime_type")
        sourceUrl = try map.value("source_url")
    }
}
