//
// Created by Arjan Duijzer on 08/03/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import OrderedDictionary
@testable import DuitslandNieuws

extension Media {
    static func createTestMedia(_ id: String) -> Media {
        return Media(id: id,
                date: Date(),
                title: RenderableText(rendered: "Title", protected: true),
                author: "author-id",
                slug: "slug",
                caption: RenderableText(rendered: "Caption", protected: false),
                details: MediaDetails.createTestMedia())
    }
}

extension MediaDetails {
    static func createTestMedia() -> MediaDetails{
        let item = MediaItem(file: "media_item_small.jpg", width: 5, height:6, mimeType: "mime/jpeg", sourceUrl: "http://image.url.com/image_id/34.jpg")
        return MediaDetails(width: 10, height: 12, file: "filename.jpg", sizes: ["key": item])
    }
}

class MediaCacheTest: XCTestCase {

    func test_get() {
        /// Given
        let testMedia = Media.createTestMedia("123")
        var dict = OrderedDictionary<String, Media>()
        dict[testMedia.key] = testMedia
        let cache = MediaCache(values: dict)

        /// When - wrong id
        let scheduler = TestScheduler(initialClock: 0)
        let recorder = scheduler.start {
            cache.get("wrong-id")
        }

        /// Then
        let expected: [Recorded<Event<Media>>] = [
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
                next(200, testMedia),
                completed(200)
        ]
        XCTAssertEqual(recorder2.events, expected2)
    }

    func test_list() {
        /// Given
        let testMedia1 = Media.createTestMedia("1")
        let testMedia2 = Media.createTestMedia("2")
        var dict = OrderedDictionary<String, Media>()
        dict[testMedia1.key] = testMedia1
        dict[testMedia2.key] = testMedia2
        let cache = MediaCache(values: dict)

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
                next(200, testMedia1),
                next(200, testMedia2),
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
        let expected2: [Recorded<Event<Media>>] = [
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
                next(200, testMedia2),
                completed(200)
        ]
        XCTAssertEqual(recorder3.events, expected3)
    }

    func test_list_all() {
        /// Given
        let testMedia1 = Media.createTestMedia("1")
        let testMedia2 = Media.createTestMedia("2")
        var dict = OrderedDictionary<String, Media>()
        dict[testMedia1.key] = testMedia1
        dict[testMedia2.key] = testMedia2
        let cache = MediaCache(values: dict)

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
                next(200, testMedia1),
                next(200, testMedia2),
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)
    }

    func test_save() {
        /// Given
        let mediaItem = Media.createTestMedia("123")
        let cache = MediaCache()

        /// When
        let scheduler = TestScheduler(initialClock: 0)
        let recorder = scheduler.start {
            cache.save(mediaItem)
        }

        /// Then
        let expectedArticle = mediaItem
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
        let cache = MediaCache()
        let testMedia1 = Media.createTestMedia("1")
        let testMedia2 = Media.createTestMedia("2")

        /// When
        let scheduler = TestScheduler(initialClock: 0)
        let recorder = scheduler.start {
            cache.save([testMedia1, testMedia2])
                    .flatMap {
                        Observable.from($0)
                    }
        }

        /// Then
        let expected = [
                next(200, testMedia1),
                next(200, testMedia2),
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
        let testMedia1 = Media.createTestMedia("1")
        let testMedia2 = Media.createTestMedia("2")
        var dict = OrderedDictionary<String, Media>()
        dict[testMedia1.key] = testMedia1
        dict[testMedia2.key] = testMedia2
        let cache = MediaCache(values: dict)

        /// When
        let scheduler = TestScheduler(initialClock: 0)
        let recorder = scheduler.start {
            cache.delete(id: "1")
        }

        /// Then
        let expected = [
                next(200, testMedia1),
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
                next(200, testMedia2),
                completed(200)
        ]
        XCTAssertEqual(recorder2.events, expected2)
    }

    func test_delete_value() {
        /// Given
        let testMedia1 = Media.createTestMedia("1")
        let testMedia2 = Media.createTestMedia("2")
        var dict = OrderedDictionary<String, Media>()
        dict[testMedia1.key] = testMedia1
        dict[testMedia2.key] = testMedia2
        let cache = MediaCache(values: dict)

        /// When
        let scheduler = TestScheduler(initialClock: 0)
        let recorder = scheduler.start {
            cache.delete(testMedia2)
        }

        /// Then
        let expected = [
                next(200, testMedia2),
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
                next(200, testMedia1),
                completed(200)
        ]
        XCTAssertEqual(recorder2.events, expected2)
    }

    func test_deleteAll() {
        /// Given
        let testMedia1 = Media.createTestMedia("1")
        let testMedia2 = Media.createTestMedia("2")
        let testMedia3 = Media.createTestMedia("3")
        var dict = OrderedDictionary<String, Media>()
        dict[testMedia1.key] = testMedia1
        dict[testMedia2.key] = testMedia2
        dict[testMedia3.key] = testMedia3
        let cache = MediaCache(values: dict)

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
                next(200, testMedia1),
                next(200, testMedia2),
                next(200, testMedia3),
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
        let expected2: [Recorded<Event<Media>>] = [
                completed(200)
        ]
        XCTAssertEqual(recorder2.events, expected2)
    }
}