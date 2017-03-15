//
// Created by Arjan Duijzer on 15/03/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import Swinject
import RxSwift

class ScheduleAssembly: Assembly {

    func assemble(container: Container) {
        /// Schedulers
        container.register(SchedulerProvider.self) { _ in
                    DefaultSchedulerProvider()
                }
                .inObjectScope(.container) /// Singleton

    }

    func loaded(resolver: Resolver) {
    }

}
