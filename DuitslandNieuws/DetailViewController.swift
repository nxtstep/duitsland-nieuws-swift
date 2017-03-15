//
//  DetailViewController.swift
//  DuitslandNieuws
//
//  Created by Arjan Duijzer on 14/02/2017.
//  Copyright © 2017 SuperSimple.io. All rights reserved.
//

import UIKit
import RxSwift
import RxMoya
import AlamofireImage

class DetailViewController: RxViewController, ArticleDetailView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!

    var articleId: String!

    // Inject
    var schedulerProvider: SchedulerProvider!
    var articleInteractor: ArticleInteractor!
    var articlePresenter: ArticleDetailPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()

        articlePresenter = ArticleDetailPresenter(id: articleId,
                interactor: articleInteractor,
                mainScheduler: schedulerProvider.main,
                ioScheduler: schedulerProvider.io)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        articlePresenter.bind(view: self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        articlePresenter.unbind()
        super.viewWillDisappear(animated)
    }


    override func setupRx() {
        super.setupRx()


    }

    func display(article: ArticleDetailPresentation) {
        self.titleLabel.setText(html: article.title, encoding: .isoLatin1)
        self.captionLabel.setText(html: article.caption ?? "", encoding: .isoLatin1)
        self.dateLabel.text = article.pubDate
        self.textLabel.setText(html: article.text, encoding: .isoLatin1)

        guard let imageUrl = article.imageUrl, let url = URL(string: imageUrl) else {
            self.imageView.image = nil
            return
        }
        self.imageView.af_setImage(withURL: url,
                placeholderImage: nil,
                filter: AspectScaledToFillSizeFilter(size: self.imageView.bounds.size))
    }
    var loading: Bool = false {
        didSet {
            // TODO - show hide loading indicator
            if loading {
                display(article: ArticleDetailPresentation.empty)
            }
        }
    }
    var error: Error? {
        didSet {
            // TODO display error
        }
    }

}
