//
// Created by Arjan Duijzer on 02/03/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import OrderedDictionary
@testable import DuitslandNieuws

class ArticleCacheTest: XCTestCase {

    func test_get() {
        /// Given
        let testArticle = Article(articleId: "123")
        var dict = OrderedDictionary<String, Article>()
        dict[testArticle.key] = testArticle
        let cache = ArticleCache(values: dict)

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
        let testArticle1 = Article(articleId: "1")
        let testArticle2 = Article(articleId: "2")
        var dict = OrderedDictionary<String, Article>()
        dict[testArticle1.key] = testArticle1
        dict[testArticle2.key] = testArticle2
        let cache = ArticleCache(values: dict)

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
        let testArticle1 = Article(articleId: "1")
        let testArticle2 = Article(articleId: "2")
        var dict = OrderedDictionary<String, Article>()
        dict[testArticle1.key] = testArticle1
        dict[testArticle2.key] = testArticle2
        let cache = ArticleCache(values: dict)

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
        let cache = ArticleCache()

        /// When
        let scheduler = TestScheduler(initialClock: 0)
        let recorder = scheduler.start {
            cache.save(Article(articleId: "123"))
        }

        /// Then
        let expectedArticle = Article(articleId: "123")
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
        let testArticle1 = Article(articleId: "1")
        let testArticle2 = Article(articleId: "2")

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
        let testArticle1 = Article(articleId: "1")
        let testArticle2 = Article(articleId: "2")
        var dict = OrderedDictionary<String, Article>()
        dict[testArticle1.key] = testArticle1
        dict[testArticle2.key] = testArticle2
        let cache = ArticleCache(values: dict)

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
        let testArticle1 = Article(articleId: "1")
        let testArticle2 = Article(articleId: "2")
        var dict = OrderedDictionary<String, Article>()
        dict[testArticle1.key] = testArticle1
        dict[testArticle2.key] = testArticle2
        let cache = ArticleCache(values: dict)

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
        let testArticle1 = Article(articleId: "1")
        let testArticle2 = Article(articleId: "2")
        let testArticle3 = Article(articleId: "3")
        var dict = OrderedDictionary<String, Article>()
        dict[testArticle1.key] = testArticle1
        dict[testArticle2.key] = testArticle2
        dict[testArticle3.key] = testArticle3
        let cache = ArticleCache(values: dict)

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

