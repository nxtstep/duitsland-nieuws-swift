//
// Created by Arjan Duijzer on 10/03/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

protocol ArticleDetailView {
    func display(article: ArticleDetailPresentation)

    var loading: Bool { get set }
    var error: Error? { get set }
}

class ArticleDetailPresenter {

    enum LoadingState {
        case LOADING
        case FINISHED
        case ERROR
    }

    var view: ArticleDetailView?
    var disposeBag: DisposeBag?

    let articleId: String
    let articleInteractor: ArticleInteractor
    let mainScheduler: SchedulerType
    let ioScheduler: SchedulerType
    let dateFormatter: DateFormatter

    fileprivate let stateSubject = PublishSubject<LoadingState>()

    init(id: String,
         interactor: ArticleInteractor,
         mainScheduler: SchedulerType,
         ioScheduler: SchedulerType,
         dateFormat: String = "H:mm - d MMMM yyyy"
    ) {
        self.articleId = id
        self.articleInteractor = interactor
        self.mainScheduler = mainScheduler
        self.ioScheduler = ioScheduler
        self.dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
    }

    func bind(view: ArticleDetailView) {
        self.disposeBag = DisposeBag()
        self.view = view

        stateSubject.asObservable()
                .observeOn(mainScheduler)
                .subscribe(onNext: { [unowned self] in self.view?.loading = ($0 == LoadingState.LOADING) })
                .disposed(by: disposeBag!)

        articleInteractor.get(articleId: articleId)
                .do(onCompleted: { [unowned self] in self.stateSubject.onNext(LoadingState.FINISHED) },
                        onSubscribe: { [unowned self] in self.stateSubject.onNext(LoadingState.LOADING) })
                .map { [unowned self] in
                    ArticleDetailPresenter.convertToDetailPresentation(article: $0.0, media: $0.1, dateFormatter: self.dateFormatter)
                }
                .subscribeOn(ioScheduler)
                .observeOn(mainScheduler)
                .subscribe(onNext: { [unowned self] in self.view?.display(article: $0) },
                        onError: { [unowned self] in self.view?.error = $0 })
                .disposed(by: disposeBag!)

    }

    func unbind() {
        self.disposeBag = nil
        self.view = nil
    }

    static func convertToDetailPresentation(article: Article, media: Media, dateFormatter: DateFormatter) -> ArticleDetailPresentation {
        return ArticleDetailPresentation.from(article: article, and: media, using: dateFormatter)
    }
}
