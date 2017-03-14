//
// Created by Arjan Duijzer on 08/03/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import Foundation
import RxSwift

class ArticleInteractor {
    let articleRepository: ArticleRepository
    let mediaRepository: MediaRepository

    init(_ articleRepo: ArticleRepository, _ mediaRepo: MediaRepository) {
        self.articleRepository = articleRepo
        self.mediaRepository = mediaRepo
    }

    func get(articleId: String) -> Observable<(Article, Media)> {
        return articleRepository.get(articleId: articleId)
                .flatMap { [unowned self] in
                    self.mergeWithMedia(article: $0)
                }
    }

    func list(page: Int, pageSize: Int) -> Observable<(Article, Media)> {
        return articleRepository.list(page, pageSize: pageSize)
                .flatMap {
                    Observable.from($0)
                            .concatMap { [unowned self] in
                                self.mergeWithMedia(article: $0)
                            }
                }
    }

    func refresh(pageSize: Int) -> Observable<(Article, Media)> {
        return articleRepository.refresh(pageSize)
                .flatMap {
                    Observable.from($0)
                            .concatMap { [unowned self] in
                                self.mergeWithMedia(article: $0)
                            }
                }
    }

    private func mergeWithMedia(article: Article) -> Observable<(Article, Media)> {
        return Observable.just(article)
                .zip(with: mediaRepository.get(id: article.featured_media)
                        .catchErrorJustReturn(Media.empty)
                        .ifEmpty(default: Media.empty)) {
                    ($0, $1)
                }
    }
}
