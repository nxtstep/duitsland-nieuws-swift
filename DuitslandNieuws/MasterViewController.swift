//
//  MasterViewController.swift
//  DuitslandNieuws
//
//  Created by Arjan Duijzer on 14/02/2017.
//  Copyright © 2017 SuperSimple.io. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxMoya


let kArticleCellIdentifier = "ArticleCellIdentifier"
let kArticleDetailSegueIdentifier = "articleDetail"

class MasterViewController: RxViewController, ArticleListView {

    @IBOutlet var articleTableView: UITableView!

    var detailViewController: DetailViewController? = nil

    // TODO Inject
    let articleListViewModel = ArticleListViewModel(mainScheduler: MainScheduler.instance,
            ioScheduler: ConcurrentDispatchQueueScheduler(qos: .background),
            interactor: ArticleInteractor(ArticleRepository(ArticleCache(), ArticleCloud(provider: RxMoyaProvider<ArticleEndpoint>())), MediaRepository(MediaCache(), MediaCloud(provider: RxMoyaProvider<MediaEndpoint>()))))

    override func viewDidLoad() {
        super.viewDidLoad()

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count - 1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        articleListViewModel.bind(view: self)
        if let indexPath = articleTableView.indexPathForSelectedRow {
            articleTableView.deselectRow(at: indexPath, animated: animated)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        articleListViewModel.unbind()
        super.viewWillDisappear(animated)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kArticleDetailSegueIdentifier {
            if let indexPath = self.articleTableView.indexPathForSelectedRow {
                let articleId = articleListViewModel[indexPath.row].articleId
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.articleId = articleId
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - ArticleListView

    var loading: Bool = false {
        didSet {
            //TODO - show/hide loading indicator
        }
    }
    var error: Error? = nil {
        didSet {
           // TODO display error
        }
    }

    // MARK: - Rx
    override func setupRx() {
        articleListViewModel.list
                .observeOn(MainScheduler.instance)
                .bindTo(articleTableView.rx.items) { (tableView, row, articlePresentation) in
                    let cell = tableView.dequeueReusableCell(withIdentifier: kArticleCellIdentifier, for: IndexPath(row: row, section: 0)) as! ArticlePresentationCell
                    cell.article = articlePresentation

                    return cell
                }
                .disposed(by: disposeBag)
    }
}
