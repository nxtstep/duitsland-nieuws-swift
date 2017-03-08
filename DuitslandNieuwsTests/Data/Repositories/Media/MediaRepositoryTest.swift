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

class MediaRepositoryTest: XCTestCase {
    static let testItem = Media.createTestMedia("3")

    func test_get() {
        /// Given
        let mockCache = MockMediaCache()
        stub(mockCache) { stub in
            when(stub.get(anyString())).thenReturn(Observable.empty())
            when(stub.save(any(Media.self))).then { media in
                        return Observable.just(media)
                    }
        }

        let mockMediaProvider = RxMoyaProvider<MediaEndpoint>()
        let mockCloud = MockMediaCloud(provider: mockMediaProvider)
        stub(mockCloud) { stub in
            when(stub.fetch(id: anyString())).thenReturn(Observable.just(MediaRepositoryTest.testItem))
        }

        let repo = MediaRepository(mockCache, mockCloud)
        let scheduler = TestScheduler(initialClock: 0)

        /// When
        let recorder = scheduler.start {
            repo.get(id: "123")
        }

        /// Then
        let expected = [
                next(200, MediaRepositoryTest.testItem),
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)

        verify(mockCache, times(1)).get("123")
        verify(mockCache, times(1)).save(equal(to: MediaRepositoryTest.testItem))
        verify(mockCloud, times(1)).fetch(id: "123")
    }

    func test_save() {
        /// Given
        let mockCache = MockMediaCache()
        stub(mockCache) { stub in
            when(stub.save(any(Media.self))).then { media in
                        return Observable.just(media)
                    }
            when(stub.save(any([Media].self))).then { list in
                        return Observable.just(list)
                    }
        }

        /// Cloud mock
        let mockMediaProvider = RxMoyaProvider<MediaEndpoint>()
        let mockCloud = MockMediaCloud(provider: mockMediaProvider)

        let repo = MediaRepository(mockCache, mockCloud)
        let scheduler = TestScheduler(initialClock: 0)

        /// When
        let recorder = scheduler.start {
            repo.save(media: MediaRepositoryTest.testItem)
        }

        /// Then
        let expected = [
                next(200, MediaRepositoryTest.testItem),
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)

        verify(mockCache, times(1)).save(equal(to: MediaRepositoryTest.testItem))
    }

    func test_delete() {
        /// Given
        let mockCache = MockMediaCache()
        stub(mockCache) { stub in
            when(stub.delete(any(Media.self))).then { media in
                        return Observable.just(media)
                    }
            when(stub.save(any([Media].self))).then { list in
                        return Observable.just(list)
                    }
        }

        /// Cloud mock
        let mockMediaProvider = RxMoyaProvider<MediaEndpoint>()
        let mockCloud = MockMediaCloud(provider: mockMediaProvider)

        let repo = MediaRepository(mockCache, mockCloud)
        let scheduler = TestScheduler(initialClock: 0)

        /// When
        let recorder = scheduler.start {
            repo.delete(media: MediaRepositoryTest.testItem)
        }

        /// Then
        let expected = [
                next(200, MediaRepositoryTest.testItem),
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)

        verify(mockCache, times(1)).delete(equal(to: MediaRepositoryTest.testItem))
    }

    func test_clear_caches() {
        /// Given
        let mockCache = MockMediaCache()
        stub(mockCache) { stub in
            when(stub.deleteAll()).thenReturn(Observable.just([Media]()))
        }

        /// Cloud mock
        let mockMediaProvider = RxMoyaProvider<MediaEndpoint>()
        let mockCloud = MockMediaCloud(provider: mockMediaProvider)

        let repo = MediaRepository(mockCache, mockCloud)
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
