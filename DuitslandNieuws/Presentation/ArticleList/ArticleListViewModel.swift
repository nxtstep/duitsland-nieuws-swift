//
// Created by Arjan Duijzer on 07/03/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol ArticleListView {
    var loading: Bool { get set }
    var error: Error? { get set }
}

class ArticleListViewModel {

    let mainScheduler: SchedulerType
    let ioScheduler: SchedulerType
    let articleInteractor: ArticleInteractor
    let pageSize: Int
    let dateFormatter: DateFormatter

    init(mainScheduler: SchedulerType,
         ioScheduler: SchedulerType,
         interactor: ArticleInteractor,
         pageSize: Int = 10,
         dateFormat: String = "H:mm - d MMMM yyyy"
    ) {
        self.mainScheduler = mainScheduler
        self.ioScheduler = ioScheduler
        self.articleInteractor = interactor
        self.pageSize = pageSize
        self.dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
    }

    private var disposeBag: DisposeBag?
    private var view: ArticleListView?

    fileprivate let articleList = Variable([ArticlePresentation]())
    fileprivate var page: Int = -1
    fileprivate var pendingPage: Int = -1
    fileprivate let stateSubject = PublishSubject<LoadingState>()

    enum LoadingState {
        case LOADING
        case FINISHED
        case ERROR
    }

    public func bind(view: ArticleListView) {
        self.disposeBag = DisposeBag()
        self.view = view

        stateSubject.asObservable()
                .observeOn(mainScheduler)
                .subscribe(onNext: { self.view?.loading = LoadingState.LOADING == $0 })
                .disposed(by: disposeBag!)

        if (page == -1) {
            loadFirstPage()
        }
    }

    private func loadFirstPage() {
        page = 0;
        loadNextPage()
    }

    func loadNextPage() {
        if (pendingPage == page) {
            return
        }
        pendingPage = page
        articleInteractor.list(page: page, pageSize: pageSize)
                .do(onCompleted: { [unowned self] in self.stateSubject.onNext(LoadingState.FINISHED) },
                        onSubscribe: { [unowned self] in self.stateSubject.onNext(LoadingState.LOADING) })
                .map { [unowned self] in
                    ArticleListViewModel.convertToPresentation(article: $0.0, media: $0.1, dateFormatter: self.dateFormatter)
                }
                .subscribeOn(ioScheduler)
                .observeOn(mainScheduler)
                .subscribe(onNext: { [unowned self] item in
                    self.articleList.value += [item]
                }, onError: { [unowned self] error in
                    self.view?.error = error
                }, onCompleted: { [unowned self] in
                    self.page += 1
                })
                .disposed(by: disposeBag!)
    }

    func refresh() {
        page = 0
        pendingPage = page

        articleInteractor.refresh(pageSize: pageSize)
                .do(
                        onCompleted: { [unowned self] in
                            self.stateSubject.onNext(LoadingState.FINISHED)
                        },
                        onSubscribe: { [unowned self] in
                            self.stateSubject.onNext(LoadingState.LOADING)
                        }
                )
                .map { [unowned self] in
                    ArticleListViewModel.convertToPresentation(article: $0.0, media: $0.1, dateFormatter: self.dateFormatter)
                }
                .toArray()
                .subscribeOn(ioScheduler)
                .observeOn(mainScheduler)
                .subscribe(onNext: { [unowned self] list in
                    self.articleList.value = list
                }, onError: { [unowned self] error in
                    self.view?.error = error
                }, onCompleted: { [unowned self] in
                    self.page += 1
                })
                .disposed(by: disposeBag!)
    }

    public func unbind() {
        self.disposeBag = nil
        self.view = nil
        if (page == pendingPage) {
            page -= 1
        }
        pendingPage = -1
    }

    static func convertToPresentation(article: Article, media: Media, dateFormatter: DateFormatter) -> ArticlePresentation {
        return ArticlePresentation.from(article: article, and: media, using: dateFormatter)
    }

    public var list: Observable<[ArticlePresentation]> {
        return articleList.asObservable()
    }

    public subscript(index: Int) -> ArticlePresentation {
        get {
            return articleList.value[index]
        }
    }
}
