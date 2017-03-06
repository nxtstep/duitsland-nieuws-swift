//
// Created by Arjan Duijzer on 14/02/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import XCTest
import Cuckoo
import RxSwift
import RxTest
import RxMoya
@testable import DuitslandNieuws

class ArticleRepositoryTest: XCTestCase {
    static let testArticle = Article(articleId: "123")

    func test_list() {
        /// Given
        let mockCache = MockArticleCache()
        stub(mockCache) { stub in
            when(stub.listAll()).thenReturn(Observable.empty())
            when(stub.save(any(Article.self))).then { article in
                        return Observable.just(article)
                    }
            when(stub.save(any([Article].self))).then { list in
                        return Observable.just(list)
                    }
        }


        let mockArticleProvider = RxMoyaProvider<ArticleEndpoint>()
        let mockCloud = MockArticleCloud(provider: mockArticleProvider)
        stub(mockCloud) { stub in
            when(stub.list()).thenReturn(Observable.from([ArticleRepositoryTest.testArticle]))
        }

        let repo = ArticleRepository(mockCache, mockCloud)
        let scheduler = TestScheduler(initialClock: 0)

        /// When
        let recorder = scheduler.start {
            repo.list().flatMap {
                        Observable.from($0)
                    }
        }

        /// Then
        let expected = [
                next(200, ArticleRepositoryTest.testArticle),
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)

        verify(mockCache, times(1)).listAll()
        verify(mockCache, times(1)).save(any([Article].self))
        verify(mockCloud, times(1)).list()
    }
}
