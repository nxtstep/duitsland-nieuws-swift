//
// Created by Arjan Duijzer on 14/02/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import Foundation
import RxSwift

class ArticleRepository {
    let cache: ArticleCache
    let cloud: ArticleCloud

    init(_ cache: ArticleCache, _ cloud: ArticleCloud) {
        self.cache = cache
        self.cloud = cloud
    }

    func list() -> Observable<[Article]> {
        return cache.list()
                .ifEmpty(switchTo: cloud.list()
                        .flatMap { [unowned self] in
                            self.cache.save($0)
                        })
    }

}
