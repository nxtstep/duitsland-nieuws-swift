//
// Created by Arjan Duijzer on 02/03/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
@testable import DuitslandNieuws

extension Article {
    static func createTestArticle(_ id: String) -> Article {
        return Article(articleId: id,
                date: Date(),
                modified: Date(),
                slug: "slug",
                link: "http://www.link.com/",
                title: RenderableText(rendered: "Title", protected: true),
                content: RenderableText(rendered: "Content", protected: false),
                excerpt: RenderableText(rendered: "Excerpt", protected: false),
                author: "author-id",
                featured_media: "media-id")
    }
}

class ArticleCacheTest: XCTestCase {

    func test_get() {
        /// Given
        let testArticle = Article.createTestArticle("123")
        let cache = ArticleCache([testArticle])

        /// When - wrong id
        let scheduler = TestScheduler(initialClock: 0)
        let recorder = scheduler.start {
            cache.get("wrong-id")
        }

        /// Then
        let expected: [Recorded<Event<Article>>] = [
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)

        //When - right id
        let scheduler2 = TestScheduler(initialClock: 0)
        let recorder2 = scheduler2.start {
            cache.get("123")
        }

        /// Then
        let expected2 = [
                next(200, testArticle),
                completed(200)
        ]
        XCTAssertEqual(recorder2.events, expected2)
    }

    func test_list() {
        /// Given
        let testArticle1 = Article.createTestArticle("1")
        let testArticle2 = Article.createTestArticle("2")
        let cache = ArticleCache([testArticle1, testArticle2])

        /// When
        let scheduler = TestScheduler(initialClock: 0)
        let recorder = scheduler.start {
            cache.list(0, pageSize: 2)
                    .flatMap {
                        Observable.from($0)
                    }
        }

        /// Then
        let expected = [
                next(200, testArticle1),
                next(200, testArticle2),
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)

        /// When
        let scheduler2 = TestScheduler(initialClock: 0)
        let recorder2 = scheduler2.start {
            cache.list(0, pageSize: 10)
                    .flatMap {
                        Observable.from($0)
                    }
        }

        /// Then
        let expected2: [Recorded<Event<Article>>] = [
                completed(200)
        ]
        XCTAssertEqual(recorder2.events, expected2)

        /// When
        let scheduler3 = TestScheduler(initialClock: 0)
        let recorder3 = scheduler3.start {
            cache.list(1, pageSize: 1)
                    .flatMap {
                        Observable.from($0)
                    }
        }

        /// Then
        let expected3 = [
                next(200, testArticle2),
                completed(200)
        ]
        XCTAssertEqual(recorder3.events, expected3)
    }

    func test_list_all() {
        /// Given
        let testArticle1 = Article.createTestArticle("1")
        let testArticle2 = Article.createTestArticle("2")
        let cache = ArticleCache([testArticle1, testArticle2])

        /// When
        let scheduler = TestScheduler(initialClock: 0)
        let recorder = scheduler.start {
            cache.listAll()
                    .flatMap {
                        Observable.from($0)
                    }
        }

        /// Then
        let expected = [
                next(200, testArticle1),
                next(200, testArticle2),
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)
    }

    func test_save() {
        /// Given
        let article = Article.createTestArticle("123")
        let cache = ArticleCache()

        /// When
        let scheduler = TestScheduler(initialClock: 0)
        let recorder = scheduler.start {
            cache.save(article)
        }

        /// Then
        let expectedArticle = article
        let expected = [
                next(200, expectedArticle),
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)
        let scheduler2 = TestScheduler(initialClock: 0)
        let recorder2 = scheduler2.start {
            cache.get("123")
        }
        XCTAssertEqual(recorder2.events, expected)
    }

    func test_save_list() {
        /// Given
        let cache = ArticleCache()
        let testArticle1 = Article.createTestArticle("1")
        let testArticle2 = Article.createTestArticle("2")

        /// When
        let scheduler = TestScheduler(initialClock: 0)
        let recorder = scheduler.start {
            cache.save([testArticle1, testArticle2])
                    .flatMap {
                        Observable.from($0)
                    }
        }

        /// Then
        let expected = [
                next(200, testArticle1),
                next(200, testArticle2),
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)
        let scheduler2 = TestScheduler(initialClock: 0)
        let recorder2 = scheduler2.start {
            cache.listAll()
                    .flatMap {
                        Observable.from($0)
                    }
        }
        XCTAssertEqual(recorder2.events, expected)
    }

    func test_delete_id() {
        /// Given
        let testArticle1 = Article.createTestArticle("1")
        let testArticle2 = Article.createTestArticle("2")
        let cache = ArticleCache([testArticle1, testArticle2])

        /// When
        let scheduler = TestScheduler(initialClock: 0)
        let recorder = scheduler.start {
            cache.delete(id: "1")
        }

        /// Then
        let expected = [
                next(200, testArticle1),
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)
        let scheduler2 = TestScheduler(initialClock: 0)
        let recorder2 = scheduler2.start {
            cache.listAll()
                    .flatMap {
                        Observable.from($0)
                    }
        }
        let expected2 = [
                next(200, testArticle2),
                completed(200)
        ]
        XCTAssertEqual(recorder2.events, expected2)
    }

    func test_delete_value() {
        /// Given
        let testArticle1 = Article.createTestArticle("1")
        let testArticle2 = Article.createTestArticle("2")
        let cache = ArticleCache([testArticle1, testArticle2])

        /// When
        let scheduler = TestScheduler(initialClock: 0)
        let recorder = scheduler.start {
            cache.delete(testArticle2)
        }

        /// Then
        let expected = [
                next(200, testArticle2),
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)

        let scheduler2 = TestScheduler(initialClock: 0)
        let recorder2 = scheduler2.start {
            cache.listAll()
                    .flatMap {
                        Observable.from($0)
                    }
        }
        let expected2 = [
                next(200, testArticle1),
                completed(200)
        ]
        XCTAssertEqual(recorder2.events, expected2)
    }

    func test_deleteAll() {
        /// Given
        let testArticle1 = Article.createTestArticle("1")
        let testArticle2 = Article.createTestArticle("2")
        let testArticle3 = Article.createTestArticle("3")
        let cache = ArticleCache([testArticle1, testArticle2, testArticle3])

        /// When
        let scheduler = TestScheduler(initialClock: 0)
        let recorder = scheduler.start {
            cache.deleteAll()
                    .flatMap {
                        Observable.from($0)
                    }
        }

        /// Then
        let expected = [
                next(200, testArticle1),
                next(200, testArticle2),
                next(200, testArticle3),
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)

        let scheduler2 = TestScheduler(initialClock: 0)
        let recorder2 = scheduler2.start {
            cache.listAll()
                    .flatMap {
                        Observable.from($0)
                    }
        }
        let expected2: [Recorded<Event<Article>>] = [
                completed(200)
        ]
        XCTAssertEqual(recorder2.events, expected2)
    }
}

