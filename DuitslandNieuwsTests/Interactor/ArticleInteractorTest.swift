//
// Created by Arjan Duijzer on 08/03/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import XCTest
import Cuckoo
import RxSwift
import RxTest
import RxMoya
@testable import DuitslandNieuws

struct Pair<F:Equatable, S:Equatable> {
    let first: F
    let second: S
}

extension Pair: Equatable {
}

func ==<F, S>(lhs: Pair<F, S>, rhs: Pair<F, S>) -> Bool {
    return lhs.first == rhs.first && lhs.second == rhs.second
}

class ArticleInteractorTest: XCTestCase {

    var mockArticleRepo: MockArticleRepository!
    var mockMediaRepo: MockMediaRepository!

    override func setUp() {
        super.setUp()

        let mockArticleProvider = RxMoyaProvider<ArticleEndpoint>()
        mockArticleRepo = MockArticleRepository(ArticleCache(), ArticleCloud(provider: mockArticleProvider))
        let mockMediaProvider = RxMoyaProvider<MediaEndpoint>()
        mockMediaRepo = MockMediaRepository(MediaCache(), MediaCloud(provider: mockMediaProvider))
    }


    func test_get() {
        stub(mockArticleRepo) { stub in
            when(stub.get(articleId: anyString())).thenReturn(Observable.just(Article.testArticle))
        }
        stub(mockMediaRepo) { stub in
            when(stub.get(id: anyString())).thenReturn(Observable.just(Media.testItem))
        }

        let interactor = ArticleInteractor(mockArticleRepo, mockMediaRepo)
        let scheduler = TestScheduler(initialClock: 0)

        /// When
        let recorder = scheduler.start {
            interactor.get(articleId: "123")
                    .map {
                        Pair(first: $0.0, second: $0.1)
                    }
        }

        /// Then
        let expected = [
                next(200, Pair(first: Article.testArticle, second: Media.testItem)),
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)

        verify(mockArticleRepo, times(1)).get(articleId: "123")
        verify(mockMediaRepo, times(1)).get(id: equal(to: Article.testArticle.featured_media))

    }

    func test_list() {
        stub(mockArticleRepo) { stub in
            when(stub.list(anyInt(), pageSize: anyInt())).thenReturn(Observable.just([Article.testArticle]))
        }
        stub(mockMediaRepo) { stub in
            when(stub.get(id: anyString())).thenReturn(Observable.just(Media.testItem))
        }

        let interactor = ArticleInteractor(mockArticleRepo, mockMediaRepo)
        let scheduler = TestScheduler(initialClock: 0)

        /// When
        let recorder = scheduler.start {
            interactor.list(page: 0, pageSize: 10).map {
                        Pair(first: $0.0, second: $0.1)
                    }
        }
        let expected = [
                next(200, Pair(first: Article.testArticle, second: Media.testItem)),
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)

        verify(mockArticleRepo, never()).get(articleId: anyString())
        verify(mockArticleRepo, never()).refresh(anyInt())
        verify(mockArticleRepo, times(1)).list(equal(to: 0), pageSize: equal(to: 10))
        verify(mockMediaRepo, times(1)).get(id: equal(to: Article.testArticle.featured_media))
    }

    func test_refresh() {
        stub(mockArticleRepo) { stub in
            when(stub.refresh(anyInt())).thenReturn(Observable.just([Article.testArticle]))
        }
        // Test with no media item available
        stub(mockMediaRepo) { stub in
            when(stub.get(id: anyString())).thenReturn(Observable.empty())
        }

        let interactor = ArticleInteractor(mockArticleRepo, mockMediaRepo)
        let scheduler = TestScheduler(initialClock: 0)

        /// When
        let recorder = scheduler.start {
            interactor.refresh(pageSize: 11).map {
                        Pair(first: $0.0, second: $0.1)
                    }
        }
        let expected = [
                next(200, Pair(first: Article.testArticle, second: Media.empty)),
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)

        verify(mockArticleRepo, never()).get(articleId: anyString())
        verify(mockArticleRepo, times(1)).refresh(equal(to: 11))
        verify(mockArticleRepo, never()).list(equal(to: 0), pageSize: equal(to: 10))
        verify(mockMediaRepo, times(1)).get(id: equal(to: Article.testArticle.featured_media))
    }
}
