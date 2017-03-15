//
// Created by Arjan Duijzer on 15/03/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import RxSwift

protocol SchedulerProvider {
    var main: SchedulerType { get }
    var io: SchedulerType { get }
}

class DefaultSchedulerProvider: SchedulerProvider {
    lazy var main: SchedulerType = {
        MainScheduler.instance
    }()

    lazy var io: SchedulerType = {
        SerialDispatchQueueScheduler(qos: .background)
    }()
}
