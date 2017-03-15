//
// Created by Arjan Duijzer on 14/02/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import Foundation
import RxSwift

class ArticleRepository {
    let cache: ArticleCache
    let cloud: ArticleCloud

    static let defaultPageSize = 10

    init(_ cache: ArticleCache, _ cloud: ArticleCloud) {
        self.cache = cache
        self.cloud = cloud
    }

    func list(_ page: Int = 0, pageSize size: Int = defaultPageSize) -> Observable<[Article]> {
        return cache.list(page, pageSize: size)
                .ifEmpty(switchTo: cloud.list(page, pageSize: size)
                        .flatMap { [unowned self] in
                            self.cache.save($0)
                        })
    }

    func get(articleId id: String) -> Observable<Article> {
        return cache.get(id)
                .ifEmpty(switchTo: cloud.fetch(id: id)
                        .flatMap { [unowned self] in
                            self.cache.save($0)
                        })
    }

    func refresh(_ pageSize: Int) -> Observable<[Article]> {
        return cache.deleteAll()
                .flatMap { [unowned self] (_) in
                    self.list(0, pageSize: pageSize)
                }
    }

    func save(_ article: Article) -> Observable<Article> {
        return cache.save(article)
    }

    func save(list articles: [Article]) -> Observable<[Article]> {
        return cache.save(articles)
    }

    func delete(_ article: Article) -> Observable<Article> {
        return cache.delete(article)
    }

    func clearCaches() -> Observable<Void> {
        return cache.deleteAll().flatMap { _ in
            Observable.empty()
        }
    }
}
