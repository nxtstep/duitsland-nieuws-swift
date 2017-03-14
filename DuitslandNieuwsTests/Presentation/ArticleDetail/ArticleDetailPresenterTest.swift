//
// Created by Arjan Duijzer on 14/03/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import XCTest
import Cuckoo
import RxSwift
import RxTest
import RxMoya
@testable import DuitslandNieuws

class ArticleDetailPresenterTest: XCTestCase {

    var mockArticleInteractor: MockArticleInteractor!
    var mockView: MockArticleDetailView!

    override func setUp() {
        super.setUp()

        let articleRepo = MockArticleRepository(ArticleCache(), ArticleCloud(provider: RxMoyaProvider<ArticleEndpoint>()))
        let mediaRepo = MockMediaRepository(MediaCache(), MediaCloud(provider: RxMoyaProvider<MediaEndpoint>()))
        mockArticleInteractor = MockArticleInteractor(articleRepo, mediaRepo)

        mockView = MockArticleDetailView()
    }

    func testArticleDetailPresenter_display() {
        ///Given
        stub(mockArticleInteractor) { stub in
            when(stub.get(articleId: anyString())).thenReturn(Observable.just((Article.testArticle, Media.testItem)))
        }

        let dateFormat = "dd.MM.yyyy"

        let scheduler = TestScheduler(initialClock: 0)
        let presenter = ArticleDetailPresenter(id: "article-id",
                interactor: mockArticleInteractor,
                mainScheduler: scheduler,
                ioScheduler: scheduler,
                dateFormat: dateFormat)

        /// When
        presenter.bind(view: mockView)
        scheduler.start()

        /// Then
        verify(mockArticleInteractor, times(1)).get(articleId: equal(to: "article-id"))
        XCTAssertEqual(mockView.errorSetCalls, 0)
        XCTAssertEqual(mockView.loadingSetCalls, 2)
        XCTAssertFalse(mockView.loading)
        XCTAssertTrue(mockView.didDisplay)
        guard let presentation = mockView.didDisplayArticle else {
            XCTAssertTrue(false, "Display article detail presentation was not set")
            return
        }
        XCTAssertEqual(presentation.articleId, Article.testArticle.articleId)
        XCTAssertEqual(presentation.text, Article.testArticle.content.rendered)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        XCTAssertEqual(presentation.pubDate, dateFormatter.string(from: Article.testArticle.date))
        XCTAssertEqual(presentation.title, Article.testArticle.title.rendered)
        XCTAssertEqual(presentation.imageUrl, Media.testItem.details.sizes[MediaItem.IMAGE_FULL]?.sourceUrl)
        XCTAssertEqual(presentation.imageUrl, "http://image.url.com/image_id/34_big.jpg")
    }
}

class MockArticleDetailView: ArticleDetailView {
    var didDisplay: Bool = false
    var didDisplayArticle: ArticleDetailPresentation? = nil

    func display(article: ArticleDetailPresentation) {
        didDisplay = true
        didDisplayArticle = article
    }
    var loadingSetCalls = 0
    var _loading: Bool = false
    var loading: Bool {
        get {
            return _loading
        }
        set {
            loadingSetCalls += 1
            _loading = newValue
        }
    }

    var errorSetCalls = 0
    var _error: Error?
    var error: Error? {
        get {
            return _error
        }
        set {
            errorSetCalls += 1
            _error = newValue
        }
    }
}
