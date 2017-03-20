//
// Created by Arjan Duijzer on 15/02/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import OrderedDictionary
@testable import DuitslandNieuws

extension String: Identifiable {
    public var key: String {
        return "id:\(self)"
    }
}

class ObservableMemCacheTest: XCTestCase {

    func test_get() {
        /// Given
        let cache = ObservableMemCache<String>()
        cache.cache.value["test-id".key] = "test-id"

        /// When - wrong id
        let scheduler = TestScheduler(initialClock: 0)
        let recorder = scheduler.start {
            cache.get("test-id")
        }

        /// Then
        let expected: [Recorded<Event<String>>] = [
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)

        //When - right id
        let scheduler2 = TestScheduler(initialClock: 0)
        let recorder2 = scheduler2.start {
            cache.get("test-id".key)
        }

        /// Then
        let expected2 = [
                next(200, "test-id"),
                completed(200)
        ]
        XCTAssertEqual(recorder2.events, expected2)
    }

    func test_list() {
        /// Given
        let cache = ObservableMemCache<String>()
        cache.cache.value["test-value-1".key] = "test-value-1"
        cache.cache.value["test-value-2".key] = "test-value-2"

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
                next(200, "test-value-1"),
                next(200, "test-value-2"),
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
        let expected2: [Recorded<Event<String>>] = [
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
                next(200, "test-value-2"),
                completed(200)
        ]
        XCTAssertEqual(recorder3.events, expected3)
    }

    func test_list_all() {
        /// Given
        let cache = ObservableMemCache<String>()
        cache.cache.value["test-value-1".key] = "test-value-1"
        cache.cache.value["test-value-2".key] = "test-value-2"

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
                next(200, "test-value-1"),
                next(200, "test-value-2"),
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)
    }

    func test_save() {
        /// Given
        let cache = ObservableMemCache<String>()

        /// When
        let scheduler = TestScheduler(initialClock: 0)
        let recorder = scheduler.start {
            cache.save("save-value")
        }

        /// Then
        let expected = [
                next(200, "save-value"),
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)
        XCTAssertNotNil(cache.cache.value["save-value".key])
    }

    func test_save_list() {
        /// Given
        let cache = ObservableMemCache<String>()

        /// When
        let scheduler = TestScheduler(initialClock: 0)
        let recorder = scheduler.start {
            cache.save(["save-value-1", "save-value-2"])
                    .flatMap {
                        Observable.from($0)
                    }
        }

        /// Then
        let expected = [
                next(200, "save-value-1"),
                next(200, "save-value-2"),
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)
        XCTAssertNotNil(cache.cache.value["save-value-1".key])
        XCTAssertNotNil(cache.cache.value["save-value-2".key])
    }

    func test_delete_id() {
        /// Given
        let cache = ObservableMemCache<String>()
        cache.cache.value["test-value-1".key] = "test-value-1"
        cache.cache.value["test-value-2".key] = "test-value-2"

        /// When
        let scheduler = TestScheduler(initialClock: 0)
        let recorder = scheduler.start {
            cache.delete(id: "test-value-1".key)
        }

        /// Then
        let expected = [
                next(200, "test-value-1"),
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)
        XCTAssertNil(cache.cache.value["test-value-1".key])
        XCTAssertNotNil(cache.cache.value["test-value-2".key])
    }

    func test_delete_value() {
        /// Given
        let cache = ObservableMemCache<String>()
        cache.cache.value["test-value-1".key] = "test-value-1"
        cache.cache.value["test-value-2".key] = "test-value-2"

        /// When
        let scheduler = TestScheduler(initialClock: 0)
        let recorder = scheduler.start {
            cache.delete("test-value-2")
        }

        /// Then
        let expected = [
                next(200, "test-value-2"),
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)
        XCTAssertNotNil(cache.cache.value["test-value-1".key])
        XCTAssertNil(cache.cache.value["test-value-2".key])
    }

    func test_deleteAll() {
        /// Given
        let cache = ObservableMemCache<String>()
        cache.cache.value["test-value-1".key] = "test-value-1"
        cache.cache.value["test-value-2".key] = "test-value-2"
        cache.cache.value["test-value-3".key] = "test-value-3"

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
                next(200, "test-value-1"),
                next(200, "test-value-2"),
                next(200, "test-value-3"),
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)

        XCTAssertNil(cache.cache.value["test-value-1".key])
        XCTAssertNil(cache.cache.value["test-value-2".key])
    }

    func test_clear() {
        /// Given
        let cache = ObservableMemCache<String>()
        cache.cache.value["test-value-1".key] = "test-value-1"
        cache.cache.value["test-value-2".key] = "test-value-2"

        /// When
        cache.clear()

        /// Then
        XCTAssertNil(cache.cache.value["save-value-1".key])
        XCTAssertNil(cache.cache.value["save-value-2".key])
    }
}
