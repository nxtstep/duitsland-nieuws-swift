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

    func test_get() {
        /// Given
        let mockCache = MockArticleCache()
        stub(mockCache) { stub in
            when(stub.get(anyString())).thenReturn(Observable.empty())
            when(stub.save(any(Article.self))).then { article in
                        return Observable.just(article)
                    }
        }

        let mockArticleProvider = RxMoyaProvider<ArticleEndpoint>()
        let mockCloud = MockArticleCloud(provider: mockArticleProvider)
        stub(mockCloud) { stub in
            when(stub.fetch(id: anyString())).thenReturn(Observable.just(ArticleRepositoryTest.testArticle))
        }

        let repo = ArticleRepository(mockCache, mockCloud)
        let scheduler = TestScheduler(initialClock: 0)

        /// When
        let recorder = scheduler.start {
            repo.get(articleId: "123")
        }

        /// Then
        let expected = [
                next(200, ArticleRepositoryTest.testArticle),
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)

        verify(mockCache, times(1)).get("123")
        verify(mockCache, times(1)).save(equal(to: ArticleRepositoryTest.testArticle))
        verify(mockCloud, times(1)).fetch(id: "123")
    }

    func test_list() {
        /// Given
        let mockCache = MockArticleCache()
        stub(mockCache) { stub in
            when(stub.list(anyInt(), pageSize: anyInt())).thenReturn(Observable.empty())
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
            when(stub.list(anyInt(), pageSize: anyInt())).thenReturn(Observable.from([ArticleRepositoryTest.testArticle]))
        }

        let repo = ArticleRepository(mockCache, mockCloud)
        let scheduler = TestScheduler(initialClock: 0)

        /// When
        let recorder = scheduler.start {
            repo.list(0, pageSize: 4).flatMap {
                        Observable.from($0)
                    }
        }

        /// Then
        let expected = [
                next(200, ArticleRepositoryTest.testArticle),
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)

        verify(mockCache, times(1)).list(0, pageSize: 4)
        verify(mockCache, times(1)).save(any([Article].self))
        verify(mockCloud, times(1)).list(0, pageSize: 4)
    }

    func test_refresh() {
        /// Given
        let mockCache = MockArticleCache()
        stub(mockCache) { stub in
            when(stub.list(anyInt(), pageSize: anyInt())).thenReturn(Observable.empty())
            when(stub.deleteAll()).thenReturn(Observable.just([Article]()))
            when(stub.save(any(Article.self))).then { article in
                        return Observable.just(article)
                    }
            when(stub.save(any([Article].self))).then { list in
                        return Observable.just(list)
                    }
        }

        /// Cloud mock
        let mockArticleProvider = RxMoyaProvider<ArticleEndpoint>()
        let mockCloud = MockArticleCloud(provider: mockArticleProvider)
        stub(mockCloud) { stub in
            when(stub.list(anyInt(), pageSize: anyInt())).thenReturn(Observable.from([ArticleRepositoryTest.testArticle]))
        }

        let repo = ArticleRepository(mockCache, mockCloud)
        let scheduler = TestScheduler(initialClock: 0)

        /// When
        let recorder = scheduler.start {
            repo.refresh(3).flatMap {
                        Observable.from($0)
                    }
        }

        /// Then
        let expected = [
                next(200, ArticleRepositoryTest.testArticle),
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)

        verify(mockCache, times(1)).deleteAll()
        verify(mockCache, times(1)).save(any([Article].self))
        verify(mockCloud, times(1)).list(0, pageSize: 3)
    }

    func test_save() {
        /// Given
        let mockCache = MockArticleCache()
        stub(mockCache) { stub in
            when(stub.save(any(Article.self))).then { article in
                        return Observable.just(article)
                    }
            when(stub.save(any([Article].self))).then { list in
                        return Observable.just(list)
                    }
        }

        /// Cloud mock
        let mockArticleProvider = RxMoyaProvider<ArticleEndpoint>()
        let mockCloud = MockArticleCloud(provider: mockArticleProvider)

        let repo = ArticleRepository(mockCache, mockCloud)
        let scheduler = TestScheduler(initialClock: 0)

        /// When
        let recorder = scheduler.start {
            repo.save(ArticleRepositoryTest.testArticle)
        }

        /// Then
        let expected = [
                next(200, ArticleRepositoryTest.testArticle),
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)

        verify(mockCache, times(1)).save(equal(to: ArticleRepositoryTest.testArticle))
    }

    func test_save_list() {
        /// Given
        let mockCache = MockArticleCache()
        stub(mockCache) { stub in
            when(stub.save(any(Article.self))).then { article in
                        return Observable.just(article)
                    }
            when(stub.save(any([Article].self))).then { list in
                        return Observable.just(list)
                    }
        }

        /// Cloud mock
        let mockArticleProvider = RxMoyaProvider<ArticleEndpoint>()
        let mockCloud = MockArticleCloud(provider: mockArticleProvider)

        let repo = ArticleRepository(mockCache, mockCloud)
        let scheduler = TestScheduler(initialClock: 0)

        /// When
        let recorder = scheduler.start {
            repo.save(list: [ArticleRepositoryTest.testArticle]).flatMap {
                        Observable.from($0)
                    }
        }

        /// Then
        let expected = [
                next(200, ArticleRepositoryTest.testArticle),
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)

        verify(mockCache, times(1)).save(any([Article].self))
    }

    func test_delete() {
        /// Given
        let mockCache = MockArticleCache()
        stub(mockCache) { stub in
            when(stub.delete(any(Article.self))).then { article in
                        return Observable.just(article)
                    }
            when(stub.save(any([Article].self))).then { list in
                        return Observable.just(list)
                    }
        }

        /// Cloud mock
        let mockArticleProvider = RxMoyaProvider<ArticleEndpoint>()
        let mockCloud = MockArticleCloud(provider: mockArticleProvider)

        let repo = ArticleRepository(mockCache, mockCloud)
        let scheduler = TestScheduler(initialClock: 0)

        /// When
        let recorder = scheduler.start {
            repo.delete(ArticleRepositoryTest.testArticle)
        }

        /// Then
        let expected = [
                next(200, ArticleRepositoryTest.testArticle),
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)

        verify(mockCache, times(1)).delete(equal(to: ArticleRepositoryTest.testArticle))
    }

    func test_clear_caches() {
        /// Given
        let mockCache = MockArticleCache()
        stub(mockCache) { stub in
            when(stub.deleteAll()).thenReturn(Observable.just([Article]()))
        }

        /// Cloud mock
        let mockArticleProvider = RxMoyaProvider<ArticleEndpoint>()
        let mockCloud = MockArticleCloud(provider: mockArticleProvider)

        let repo = ArticleRepository(mockCache, mockCloud)
        let scheduler = TestScheduler(initialClock: 0)

        /// When
        let recorder = scheduler.start {
            repo.clearCaches()
        }

        /// Then
        XCTAssertTrue(recorder.events[0].value.isStopEvent)

        verify(mockCache, times(1)).deleteAll()
    }
}
