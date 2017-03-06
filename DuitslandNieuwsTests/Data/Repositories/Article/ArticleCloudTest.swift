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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let expectedArticle = Article(articleId: "50152",
                date: dateFormatter.date(from: "2017-01-23T11:55:11")!,
                modified: dateFormatter.date(from: "2017-01-23T12:04:46")!,
                slug: "waarom-frauke-petry-geert-wilders-hard-nodig",
                link: "http://duitslandnieuws.nl/blog/2017/01/23/waarom-frauke-petry-geert-wilders-hard-nodig/",
                title: RenderableText(rendered: "Waarom Frauke Petry Geert Wilders hard nodig heeft", protected: true),
                content: RenderableText(rendered: "Content", protected: false),
                excerpt: RenderableText(rendered: "Geert Wilders voerde afgelopen weekend campagne voor de AfD en stelde dat met Frauke Petry de toekomst van Duitsland verzekerd is. Tijdens de bijeenkomst van de Europese rechts-populisten in Koblenz bleek waarom Petry de Nederlandse PVV-leider goed kan gebruiken.<a class=\"read-more\" href=\"http://duitslandnieuws.nl/blog/2017/01/23/waarom-frauke-petry-geert-wilders-hard-nodig/\">--- meer ---</a>", protected: false),
                author: "78",
                featured_media: "40325")

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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let testArticle1 = Article(articleId: "49978",
                date: dateFormatter.date(from: "2017-01-08T07:24:03")!,
                modified: dateFormatter.date(from: "2017-01-08T10:20:06")!,
                slug: "wensdenken",
                link: "http://duitslandnieuws.nl/blog/2017/01/08/wensdenken/",
                title: RenderableText(rendered: "Wensdenken", protected: true),
                content: RenderableText(rendered: "<p>Deze Amerikaanse boerenknech", protected: false),
                excerpt: RenderableText(rendered: "Hij was amper 20 jaar oud en stond in de rij voor een vrachtauto die hem terug naar voren zou brengen. Naar voren. Dat was wel het laatste waar hij op zat te wachten op deze koude dag in januari. Een maand waren ze hier. Eigenlijk nog iets minder, maar het voelde als een jaar. Sinds 16 december had hij nauwelijks geslapen en het doorlopend koud gehad. Een kilometer of 15 waren ze uiteindelijk teruggetrokken. Nu dus weer de andere kant op.<a class=\"read-more\" href=\"http://duitslandnieuws.nl/blog/2017/01/08/wensdenken/\">--- meer ---</a>", protected: false),
                author: "115",
                featured_media: "49979")

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
