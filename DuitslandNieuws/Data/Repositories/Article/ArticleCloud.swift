//
// Created by Arjan Duijzer on 14/02/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import Foundation
import RxSwift
import RxMoya

class ArticleCloud {
    typealias V = Article
    typealias Endpoint = ArticleEndpoint

    let articleProvider: RxMoyaProvider<Endpoint>

    required init(provider: RxMoyaProvider<Endpoint>) {
        self.articleProvider = provider
    }

    func list() -> Observable<[V]> {
        return articleProvider.request(.list(page: 0, size: 10))
                .mapArray(Article.self)
    }

    func list(_ page: Int, pageSize size: Int) -> Observable<[V]> {
        return articleProvider.request(.list(page: page, size: size))
                .mapArray(Article.self)
    }

    func fetch(id: String) -> Observable<V> {
        return articleProvider.request(.article(id: id))
                .mapObject(Article.self)
    }
}
