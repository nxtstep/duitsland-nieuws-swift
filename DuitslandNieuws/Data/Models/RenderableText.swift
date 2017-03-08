//
// Created by Arjan Duijzer on 06/03/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import Foundation
import ObjectMapper

struct RenderableText {
    let rendered: String
    let protected: Bool
}

/// Mapping from JSON with ObjectMapper

extension RenderableText: ImmutableMappable {
    init(map: Map) throws {
        rendered = try map.value("rendered")
        protected = (try? map.value("protected")) ?? true
    }
}

extension RenderableText {
    static let empty = RenderableText(rendered: "", protected: false)
}