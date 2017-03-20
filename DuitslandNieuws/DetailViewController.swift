//
//  DetailViewController.swift
//  DuitslandNieuws
//
//  Created by Arjan Duijzer on 14/02/2017.
//  Copyright © 2017 SuperSimple.io. All rights reserved.
//

import UIKit
import AlamofireImage

class DetailViewController: UIViewController, ArticleDetailView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!

    @IBInspectable var navigationBarBackgroundColor: UIColor = UIColor(colorLiteralRed: 0.0 / 255.0, green: 175 / 255.0, blue: 240 / 255.0, alpha: 1.0)
    @IBInspectable var navigationBarTransitionOffset: CGFloat = 60.0
    @IBInspectable var tintColor: UIColor = UIColor.white

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

        /// Navigation bar
        self.navigationController?.navigationBar.cn_init()
        self.scrollView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        /// Navigation bar
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationController?.navigationBar.tintColor = tintColor
        self.title = nil

        articlePresenter.bind(view: self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        /// Navigation bar
        self.navigationController?.navigationBar.cn_reset()
        UIApplication.shared.statusBarStyle = .default

        articlePresenter.unbind()
        super.viewWillDisappear(animated)
    }

    // MARK: - ArticleDetailView
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

extension DetailViewController: UIScrollViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let navigationBar = self.navigationController?.navigationBar else {
            return
        }
        let color = navigationBarBackgroundColor
        let offsetY = scrollView.contentOffset.y
        let navBarMaxY = navigationBar.frame.maxY

        if (offsetY > navigationBarTransitionOffset) {
            let alpha = Swift.min(1.0, 1.0 - ((navigationBarTransitionOffset + navBarMaxY - offsetY) / navBarMaxY));
            navigationBar.cn_setBackground(color: color.withAlphaComponent(alpha))
        } else {
            navigationBar.cn_setBackground(color: color.withAlphaComponent(0.0))
        }
    }
}

// MARK: Custom Navigation Bar (cn)
let CN_OVERLAY_VIEW_TAG = -45433

extension UINavigationBar {
    func cn_reset() {
        self.setBackgroundImage(nil, for: UIBarMetrics.default)
        self.shadowImage = nil
        self.overlay = nil
    }

    func cn_setBackground(color: UIColor) {
        self.overlay?.backgroundColor = color
    }

    func cn_init() {
        self.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.shadowImage = UIImage()
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height + statusBarHeight))
        view.tag = CN_OVERLAY_VIEW_TAG
        view.isUserInteractionEnabled = false
        view.autoresizingMask = UIViewAutoresizing.flexibleWidth
        self.overlay = view

        self.cn_setBackground(color: UIColor.clear)
    }

    func cn_setTranslationY(_ translationY: CGFloat) {
        self.transform = CGAffineTransform(translationX: 0, y: translationY);
    }

    var overlay: UIView? {
        get {
            let view = self.subviews.first?.subviews.first { view in
                view.tag == CN_OVERLAY_VIEW_TAG
            }
            return view
        }
        set {
            if let view = self.overlay {
                view.removeFromSuperview()
            }
            if let view = newValue {
                self.subviews.first?.insertSubview(view, at: 0)
            }
        }
    }
}

