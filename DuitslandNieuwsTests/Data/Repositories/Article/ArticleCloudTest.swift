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
            return Endpoint(url: url, sampleResponseClosure: {.networkResponse(200, samplePath.sampleData)}, method: target.method, parameters: target.parameters)
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
}
