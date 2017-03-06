//
// Created by Arjan Duijzer on 03/03/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//


import Foundation
import XCTest
import RxSwift
import RxTest
import RxMoya
import Moya
@testable import DuitslandNieuws

class ArticleCloudTest: XCTestCase {

    func test_fetch() {
        /// Given
        let samplePath = testResourcePath(for: ArticleCloudTest.self, name: "post_50152.json")
        let endpointClosure = { (target: ArticleEndpoint) -> Endpoint<ArticleEndpoint> in
            let url = target.baseURL.appendingPathComponent(target.path).absoluteString
            switch target {
            case .article(_):
                return Endpoint(url: url, sampleResponseClosure: { .networkResponse(200, samplePath.sampleData) }, method: target.method, parameters: target.parameters)
            default:
                return Endpoint(url: url, sampleResponseClosure: { .networkResponse(500, Data()) }, method: target.method, parameters: target.parameters)
            }
        }

        let articleEndpoint = RxMoyaProvider<ArticleEndpoint>(endpointClosure: endpointClosure, stubClosure: MoyaProvider.immediatelyStub)
        let cloud: ArticleCloud = ArticleCloud(provider: articleEndpoint)
        let expectedArticle = Article(articleId: "50152")

        /// When
        let scheduler = TestScheduler(initialClock: 0)
        let recorder = scheduler.start {
            cloud.fetch(id: "123")
        }

        /// Then
        let expected = [
                next(200, expectedArticle),
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)
    }

    func test_list() {
        /// Given
        let testArticle1 = Article(articleId: "49978")
        let samplePath = testResourcePath(for: ArticleCloudTest.self, name: "posts_page_1_10.json")
        let endpointClosure = { (target: ArticleEndpoint) -> Endpoint<ArticleEndpoint> in
            let url = target.baseURL.appendingPathComponent(target.path).absoluteString
            switch target {
            case let .list(page, size)
                 where page == 1 && size == 10:
                return Endpoint(url: url, sampleResponseClosure: { .networkResponse(200, samplePath.sampleData) }, method: target.method, parameters: target.parameters)
            default:
                return Endpoint(url: url, sampleResponseClosure: { .networkResponse(500, Data()) }, method: target.method, parameters: target.parameters)
            }
        }

        let articleEndpoint = RxMoyaProvider<ArticleEndpoint>(endpointClosure: endpointClosure, stubClosure: MoyaProvider.immediatelyStub)
        let cloud: ArticleCloud = ArticleCloud(provider: articleEndpoint)

        /// When
        let scheduler = TestScheduler(initialClock: 0)
        let recorder = scheduler.start {
            cloud.list(0, pageSize: 10)
                    .flatMap {
                        Observable.from($0)
                    }
        }

        /// Then
        XCTAssertEqual(recorder.events.count, 11)
        XCTAssertEqual(recorder.events[0].value.element, next(200, testArticle1).value.element)
        XCTAssertEqual(recorder.events[10].value.element, completed(200).value.element)
    }
}
