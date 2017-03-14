//
// Created by Arjan Duijzer on 07/03/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import XCTest
import Cuckoo
import RxSwift
import RxTest
import RxMoya
@testable import DuitslandNieuws

class ArticleListViewModelTest: XCTestCase {

    var mockArticleInteractor: MockArticleInteractor!
    var mockListView: MockArticleListView!

    override func setUp() {
        super.setUp()

        let articleRepo = MockArticleRepository(ArticleCache(), ArticleCloud(provider: RxMoyaProvider<ArticleEndpoint>()))
        let mediaRepo = MockMediaRepository(MediaCache(), MediaCloud(provider: RxMoyaProvider<MediaEndpoint>()))
        mockArticleInteractor = MockArticleInteractor(articleRepo, mediaRepo)

        mockListView = MockArticleListView()
    }


    func testArticleListViewModel_list() {
        ///Given
        stub(mockArticleInteractor) { stub in
            when(stub.list(page: anyInt(), pageSize: anyInt())).thenReturn(Observable.just((Article.testArticle, Media.testItem)))
        }

        let dateFormat = "HH:mm:ss'T' dd.MM.yyyy"
        let pageSize = 5

        let scheduler = TestScheduler(initialClock: 0)
        let viewModel = ArticleListViewModel(mainScheduler: scheduler,
                ioScheduler: scheduler,
                interactor: mockArticleInteractor,
                pageSize: pageSize,
                dateFormat: dateFormat)

        let presentationList = Variable([ArticlePresentation]())
        /// When
        _ = viewModel.list.bindTo(presentationList)
        viewModel.bind(view: mockListView)
        scheduler.start()

        viewModel.unbind()

        /// Then
        verify(mockArticleInteractor, times(1)).list(page: equal(to: 0), pageSize: equal(to: pageSize))
        XCTAssertEqual(mockListView.errorSetCalls, 0)
        XCTAssertEqual(mockListView.loadingSetCalls, 2)
        XCTAssertFalse(mockListView.loading)
        XCTAssertEqual(presentationList.value.count, 1)
        let presentation = presentationList.value[0]
        XCTAssertEqual(presentation.articleId, Article.testArticle.articleId)
        XCTAssertEqual(presentation.excerpt, Article.testArticle.excerpt.rendered)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        XCTAssertEqual(presentation.pubDate, dateFormatter.string(from: Article.testArticle.date))
        XCTAssertEqual(presentation.title, Article.testArticle.title.rendered)
        XCTAssertEqual(presentation.imageUrl, Media.testItem.details.sizes[MediaItem.IMAGE_THUMBNAIL]?.sourceUrl)
        XCTAssertEqual(presentation.imageUrl, "http://image.url.com/image_id/34.jpg")
    }

    func testArticleListViewModel_refresh() {
        ///Given
        stub(mockArticleInteractor) { stub in
            when(stub.list(page: anyInt(), pageSize: anyInt())).thenReturn(Observable.just((Article.testArticle, Media.testItem)))
            when(stub.refresh(pageSize: anyInt())).thenReturn(Observable.just((Article.testArticle, Media.empty)))
        }

        let dateFormat = "HH:mm:ss'T' dd.MM.yyyy"
        let pageSize = 5

        let scheduler = TestScheduler(initialClock: 0)
        let viewModel = ArticleListViewModel(mainScheduler: scheduler,
                ioScheduler: scheduler,
                interactor: mockArticleInteractor,
                pageSize: pageSize,
                dateFormat: dateFormat)

        let presentationList = Variable([ArticlePresentation]())
        /// When
        _ = viewModel.list.bindTo(presentationList)
        viewModel.bind(view: mockListView)
        scheduler.start()
        viewModel.refresh()
        scheduler.start()
        viewModel.unbind()

        /// Then
        verify(mockArticleInteractor, times(1)).list(page: equal(to: 0), pageSize: equal(to: pageSize))
        verify(mockArticleInteractor, times(1)).refresh(pageSize: equal(to: pageSize))
        XCTAssertEqual(presentationList.value.count, 1)
        XCTAssertEqual(mockListView.errorSetCalls, 0)
        XCTAssertEqual(mockListView.loadingSetCalls, 4)
        XCTAssertFalse(mockListView.loading)
    }

    func testArticleListViewModel_list_more() {

    }
}

class MockArticleListView: ArticleListView {
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
