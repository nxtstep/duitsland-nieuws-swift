//
// Created by Arjan Duijzer on 15/03/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import Swinject
import SwinjectStoryboard

extension SwinjectStoryboard {

    class func setup() {
        let container = defaultContainer
        Container.loggingFunction = nil
        let assembler = try! Assembler(assemblies: [
                NetworkAssembly(),
                ViewModelAssembly(),
                RepositoryAssembly(),
                ScheduleAssembly()
        ])

        /// MasterViewController
        container.storyboardInitCompleted(MasterViewController.self) { _, c in
            let r = assembler.resolver
            c.articleInteractor = r.resolve(ArticleInteractor.self)!
            c.schedulerProvider = r.resolve(SchedulerProvider.self)!
        }

        /// DetailViewController
        container.storyboardInitCompleted(DetailViewController.self) { _, c in
            let r = assembler.resolver
            c.articleInteractor = r.resolve(ArticleInteractor.self)!
            c.schedulerProvider = r.resolve(SchedulerProvider.self)!
        }
    }
}