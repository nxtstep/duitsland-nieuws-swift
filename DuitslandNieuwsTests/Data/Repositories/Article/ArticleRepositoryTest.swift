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

extension Article {
    static let testArticle = Article(articleId: "123",
            date: Date(),
            modified: Date(),
            slug: "slug",
            link: "link",
            title: RenderableText(rendered: "Title", protected: false),
            content: RenderableText(rendered: "Content", protected: true),
            excerpt: RenderableText(rendered: "Excerpt", protected: true),
            author: "author-id",
            featured_media: "featured-media-id")
}

class ArticleRepositoryTest: XCTestCase {

    var mockCache: MockArticleCache!
    var mockCloud: MockArticleCloud!

    override func setUp() {
        super.setUp()
        mockCache = MockArticleCache()
        stub(mockCache) { stub in
            when(stub.save(any(Article.self))).then { article in
                return Observable.just(article)
            }
            when(stub.save(any([Article].self))).then { list in
                return Observable.just(list)
            }
            when(stub.deleteAll()).thenReturn(Observable.just([Article]()))
        }

        let mockArticleProvider = RxMoyaProvider<ArticleEndpoint>()
        mockCloud = MockArticleCloud(provider: mockArticleProvider)
    }


    func test_get() {
        /// Given
        stub(mockCache) { stub in
            when(stub.get(anyString())).thenReturn(Observable.empty())
        }

        stub(mockCloud) { stub in
            when(stub.fetch(id: anyString())).thenReturn(Observable.just(Article.testArticle))
        }

        let repo = ArticleRepository(mockCache, mockCloud)
        let scheduler = TestScheduler(initialClock: 0)

        /// When
        let recorder = scheduler.start {
            repo.get(articleId: "123")
        }

        /// Then
        let expected = [
                next(200, Article.testArticle),
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)

        verify(mockCache, times(1)).get("123")
        verify(mockCache, times(1)).save(equal(to: Article.testArticle))
        verify(mockCloud, times(1)).fetch(id: "123")
    }

    func test_list() {
        /// Given
        stub(mockCache) { stub in
            when(stub.list(anyInt(), pageSize: anyInt())).thenReturn(Observable.empty())

        }

        stub(mockCloud) { stub in
            when(stub.list(anyInt(), pageSize: anyInt())).thenReturn(Observable.from(optional: [Article.testArticle]))
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
                next(200, Article.testArticle),
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)

        verify(mockCache, times(1)).list(0, pageSize: 4)
        verify(mockCache, times(1)).save(any([Article].self))
        verify(mockCloud, times(1)).list(0, pageSize: 4)
    }

    func test_refresh() {
        /// Given
        stub(mockCache) { stub in
            when(stub.list(anyInt(), pageSize: anyInt())).thenReturn(Observable.empty())
        }

        /// Cloud mock
        stub(mockCloud) { stub in
            when(stub.list(anyInt(), pageSize: anyInt())).thenReturn(Observable.from(optional: [Article.testArticle]))
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
                next(200, Article.testArticle),
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)

        verify(mockCache, times(1)).deleteAll()
        verify(mockCache, times(1)).save(any([Article].self))
        verify(mockCloud, times(1)).list(0, pageSize: 3)
    }

    func test_save() {
        /// Given
        /// Cloud mock
        let repo = ArticleRepository(mockCache, mockCloud)
        let scheduler = TestScheduler(initialClock: 0)

        /// When
        let recorder = scheduler.start {
            repo.save(Article.testArticle)
        }

        /// Then
        let expected = [
                next(200, Article.testArticle),
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)

        verify(mockCache, times(1)).save(equal(to: Article.testArticle))
    }

    func test_save_list() {
        /// Given - default

        let repo = ArticleRepository(mockCache, mockCloud)
        let scheduler = TestScheduler(initialClock: 0)

        /// When
        let recorder = scheduler.start {
            repo.save(list: [Article.testArticle]).flatMap {
                Observable.from($0)
            }
        }

        /// Then
        let expected = [
                next(200, Article.testArticle),
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)

        verify(mockCache, times(1)).save(any([Article].self))
    }

    func test_delete() {
        /// Given
        stub(mockCache) { stub in
            when(stub.delete(any(Article.self))).then { article in
                return Observable.just(article)
            }
        }

        let repo = ArticleRepository(mockCache, mockCloud)
        let scheduler = TestScheduler(initialClock: 0)

        /// When
        let recorder = scheduler.start {
            repo.delete(Article.testArticle)
        }

        /// Then
        let expected = [
                next(200, Article.testArticle),
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)

        verify(mockCache, times(1)).delete(equal(to: Article.testArticle))
    }

    func test_clear_caches() {
        /// Given - default

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
