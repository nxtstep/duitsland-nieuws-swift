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

    static let defaultPageSize = 10
    
    let articleProvider: RxMoyaProvider<Endpoint>

    required init(provider: RxMoyaProvider<Endpoint>) {
        self.articleProvider = provider
    }

    func list() -> Observable<[V]> {
        return self.list(0, pageSize: ArticleCloud.defaultPageSize)
    }

    func list(_ page: Int, pageSize size: Int) -> Observable<[V]> {
        return articleProvider.request(.list(page: page + 1, size: size))
                .mapArray(Article.self)
    }

    func fetch(id: String) -> Observable<V> {
        return articleProvider.request(.article(id: id))
                .mapObject(Article.self)
    }
}
