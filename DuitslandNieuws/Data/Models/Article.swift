//
// Created by Arjan Duijzer on 14/02/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import Foundation
import ObjectMapper

struct Article {
    let articleId: String
}

/// Mapping from JSON with ObjectMapper
extension Article: ImmutableMappable {
    init(map: Map) throws {
        articleId = try map.value("id", using: TransformOf<String, Int>(fromJSON: { value in
            guard let value = value else {
                return nil
            }
            return String(value)
        }, toJSON: { value in
            return value.flatMap {
                Int($0)
            }
        }))
    }
}

extension Article: Equatable {
}

func ==(lhs: Article, rhs: Article) -> Bool {
    return lhs.articleId == rhs.articleId
}