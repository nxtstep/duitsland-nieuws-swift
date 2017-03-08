//
// Created by Arjan Duijzer on 08/03/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import Foundation
import ObjectMapper

struct Media {
    let id: String
    let date: Date
    let title: RenderableText
    let author: String
    let slug: String
    let caption: RenderableText
    let details: MediaDetails
}

/// Mapping from JSON with ObjectMapper

extension Media: ImmutableMappable {
    static let jsonDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = jsonDateFormat
        return dateFormatter
    }()

    init(map: Map) throws {
        id = try map.value("id", using: IntIdTransform())

        date = try map.value("date", using: DateFormatterTransform(dateFormatter: Media.dateFormatter))
        slug = try map.value("slug")

        title = try map.value("title")
        caption = try map.value("caption")
        author = try map.value("author", using: IntIdTransform())
        details = try map.value("media_details")
    }
}

extension Media: Equatable {
}

func ==(lhs: Media, rhs: Media) -> Bool {
    let res = lhs.id == rhs.id &&
            lhs.date == rhs.date
    return res
}
