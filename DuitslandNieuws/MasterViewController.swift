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

    @IBOutlet weak var articleTableView: UITableView!

    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControlEvents.valueChanged)
        return refreshControl
    }()

    var detailViewController: DetailViewController? = nil

    // Inject
    var schedulerProvider: SchedulerProvider!
    var articleInteractor: ArticleInteractor!
    var articleListViewModel: ArticleListViewModel!

    override func viewDidLoad() {
        articleListViewModel = ArticleListViewModel(
                mainScheduler: schedulerProvider.main,
                ioScheduler: schedulerProvider.io,
                interactor: articleInteractor)
        
        super.viewDidLoad()

        articleTableView.estimatedRowHeight = 140
        articleTableView.rowHeight = UITableViewAutomaticDimension
        articleTableView.addSubview(self.refreshControl)

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

    func handleRefresh(_ control: UIRefreshControl) {
        if control == self.refreshControl {
            articleListViewModel.refresh()
        }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kArticleDetailSegueIdentifier {
            if let indexPath = self.articleTableView.indexPathForSelectedRow {
                let article = articleListViewModel[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.articleId = article.articleId
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - ArticleListView

    var loading: Bool = false {
        didSet {
            // show/hide loading indicator
            UIApplication.shared.isNetworkActivityIndicatorVisible = loading
            if loading {
                self.refreshControl.beginRefreshing()
            } else {
                self.refreshControl.endRefreshing()
            }
        }
    }
    var error: Error? = nil {
        didSet {
            // TODO display error
            if let _ = error {
                self.refreshControl.endRefreshing()
            }
        }
    }

    // MARK: - Rx
    override func setupRx() {
        /// Bind list items to table
        articleListViewModel.list
                .observeOn(MainScheduler.instance)
                .bindTo(articleTableView.rx.items) { (tableView, row, articlePresentation) in
                    let cell = tableView.dequeueReusableCell(withIdentifier: kArticleCellIdentifier, for: IndexPath(row: row, section: 0)) as! ArticlePresentationCell
                    cell.article = articlePresentation

                    return cell
                }
                .disposed(by: disposeBag)

        /// Bind content offset to load more trigger
        articleTableView.rx.contentOffset
                .throttle(0.5, scheduler: MainScheduler.instance)
                .filter { [unowned self] offset in
                    return (offset.y + self.articleTableView.frame.size.height + 50 > self.articleTableView.contentSize.height)
                }
                .subscribe(onNext: { [unowned self] offset in
                    self.articleListViewModel.loadNextPage()
                })
                .disposed(by: disposeBag)
    }
}
