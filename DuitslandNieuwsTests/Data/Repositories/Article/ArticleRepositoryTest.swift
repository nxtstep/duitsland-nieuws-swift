//
// Created by Arjan Duijzer on 14/02/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import XCTest
import Cuckoo
import RxSwift
import RxTest
@testable import DuitslandNieuws

class ArticleRepositoryTest: XCTestCase {
    static let testArticle = Article(articleId: "123")

    func test_list() {
        /// Given
        let mockCache = MockArticleCache()
        stub(mockCache) { stub in
            when(stub.list()).thenReturn(Observable.empty())
            when(stub.save(any())).then { list in
                        return Observable.just(list)
                    }
        }

        let mockCloud = MockArticleCloud()
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

        verify(mockCache, times(1)).list()
        verify(mockCache, times(1)).save(any())
        verify(mockCloud, times(1)).list()
    }
}
