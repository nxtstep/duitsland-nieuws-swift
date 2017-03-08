//
// Created by Arjan Duijzer on 08/03/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import RxTest
import RxMoya
import Moya
@testable import DuitslandNieuws

class MediaCloudTest: XCTestCase {
    func test_fetch() {
        /// Given
        let samplePath = testResourcePath(for: MediaCloudTest.self, name: "media_49979.json")
        let endpointClosure = { (target: MediaEndpoint) -> Endpoint<MediaEndpoint> in
            let url = target.baseURL.appendingPathComponent(target.path).absoluteString
            switch target {
            case .media(_):
                return Endpoint(url: url, sampleResponseClosure: { .networkResponse(200, samplePath.sampleData) }, method: target.method, parameters: target.parameters)
            default:
                return Endpoint(url: url, sampleResponseClosure: { .networkResponse(500, Data()) }, method: target.method, parameters: target.parameters)
            }
        }

        let mediaEndpoint = RxMoyaProvider<MediaEndpoint>(endpointClosure: endpointClosure, stubClosure: MoyaProvider.immediatelyStub)
        let cloud: MediaCloud = MediaCloud(provider: mediaEndpoint)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let expectedMedia = Media(id: "49979",
                date: dateFormatter.date(from: "2017-01-07T16:16:46")!,
                title: RenderableText(rendered: "Schermafdruk 2017-01-07 16.04.53", protected: true),
                author: "78",
                slug: "schermafdruk-2017-01-07-16-04-53",
                caption: RenderableText(rendered: "Tunnel. Foto: Jose D. Saura/Wikicommons, CC<a class=\"read-more\" href=\"http://duitslandnieuws.nl/blog/2017/01/08/wensdenken/schermafdruk-2017-01-07-16-04-53/\">--- meer ---</a>", protected: true),
                details: MediaDetails(width: 1125,
                        height: 686,
                        file: "2017/01/Schermafdruk-2017-01-07-16.04.53.png",
                        sizes: ["thumbnail": MediaItem(file: "Schermafdruk-2017-01-07-16.04.53-150x150.png",
                                width: 150,
                                height: 150,
                                mimeType: "image/png",
                                sourceUrl: "http://duitslandnieuws.nl/wp-content/uploads/2017/01/Schermafdruk-2017-01-07-16.04.53-150x150.png")]))

        /// When
        let scheduler = TestScheduler(initialClock: 0)
        let recorder = scheduler.start {
            cloud.fetch(id: "123")
        }

        /// Then
        let expected = [
                next(200, expectedMedia),
                completed(200)
        ]
        XCTAssertEqual(recorder.events, expected)
        let item = recorder.events[0].value.element!
        XCTAssertEqual(item.id, "49979")
        XCTAssertEqual(item.title.rendered, "Schermafdruk 2017-01-07 16.04.53")
        XCTAssertEqual(item.author, "78")
        XCTAssertEqual(item.details.width, 1125)
        XCTAssertEqual(item.details.height, 686)
        let media = item.details.sizes["thumbnail"]!
        XCTAssertEqual(media.file, "Schermafdruk-2017-01-07-16.04.53-150x150.png")
        XCTAssertEqual(media.width, 150)
        XCTAssertEqual(media.height, 150)
        XCTAssertEqual(media.mimeType, "image/png")
        XCTAssertEqual(media.sourceUrl, "http://duitslandnieuws.nl/wp-content/uploads/2017/01/Schermafdruk-2017-01-07-16.04.53-150x150.png")
    }
}
