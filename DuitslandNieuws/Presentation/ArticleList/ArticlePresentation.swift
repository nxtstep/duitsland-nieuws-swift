//
// Created by Arjan Duijzer on 07/03/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import Foundation

struct ArticlePresentation {
    let articleId: String
    let title: String
    let pubDate: String
    let excerpt: String
    let imageUrl: String?

    static func from(article: Article, and media: Media, using dateFormatter: DateFormatter) -> ArticlePresentation {
        return ArticlePresentation(articleId: article.articleId,
                title: article.title.rendered,
                pubDate: dateFormatter.string(from: article.date),
                excerpt: article.excerpt.rendered,
                imageUrl: media.details.sizes[MediaItem.IMAGE_THUMBNAIL]?.sourceUrl)
    }
}
