//
// Created by Arjan Duijzer on 10/03/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import Foundation

struct ArticleDetailPresentation {
    let articleId: String
    let pubDate: String
    let title: String
    let text: String
    let caption: String?
    let imageUrl: String?

    static let empty = ArticleDetailPresentation(articleId: "", pubDate: "", title: "", text: "", caption: nil, imageUrl: nil)
    
    static func from(article: Article, and media: Media, using dateFormatter: DateFormatter) -> ArticleDetailPresentation {
        return ArticleDetailPresentation(articleId: article.articleId,
                pubDate: dateFormatter.string(from: article.date),
                title: article.title.rendered,
                text: article.content.rendered,
                caption: media.caption.rendered,
                imageUrl: media.details.sizes[MediaItem.IMAGE_FULL]?.sourceUrl)
    }
}
