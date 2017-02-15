//
// Created by Arjan Duijzer on 14/02/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import Foundation
import RxSwift

class ArticleCache {
    func list() -> Observable<[Article]> {
        return Observable.empty()
    }

    func save(_ list: [Article]) -> Observable<[Article]> {
        return Observable.empty()
    }
}
