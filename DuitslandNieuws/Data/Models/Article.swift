//
// Created by Arjan Duijzer on 14/02/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import Foundation
import ObjectMapper

struct Article {
    let articleId: String
    let date: Date
    let modified: Date
    let slug: String
    let link: String
    let title: RenderableText
    let content: RenderableText
    let excerpt: RenderableText
    let author: String
    let featured_media: String
}

/// Mapping from JSON with ObjectMapper

extension Article: ImmutableMappable {
    static let jsonDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = jsonDateFormat
        return dateFormatter
    }()

    init(map: Map) throws {
        articleId = try map.value("id", using: IntIdTransform())

        date = try map.value("date", using: DateFormatterTransform(dateFormatter: Article.dateFormatter))
        modified = try map.value("modified", using: DateFormatterTransform(dateFormatter: Article.dateFormatter))
        slug = try map.value("slug")
        link = try map.value("link")

        title = try map.value("title")
        content = try map.value("content")
        excerpt = try map.value("excerpt")

        author = try map.value("author", using: IntIdTransform())
        featured_media = try map.value("featured_media", using: IntIdTransform())
    }
}

extension Date {
    static let empty = Date(timeIntervalSince1970: 0)
}

extension Article {
    static let empty = Article(articleId: "", date: Date.empty, modified: Date.empty, slug: "", link: "", title: RenderableText.empty, content: RenderableText.empty, excerpt: RenderableText.empty, author: "", featured_media: "")
}

extension Article: Equatable {
}

func ==(lhs: Article, rhs: Article) -> Bool {
    let res = lhs.articleId == rhs.articleId &&
            lhs.date == rhs.date &&
            lhs.modified == rhs.modified &&
            lhs.slug == rhs.slug &&
            lhs.link == rhs.link &&
            lhs.author == rhs.author
    return res
}