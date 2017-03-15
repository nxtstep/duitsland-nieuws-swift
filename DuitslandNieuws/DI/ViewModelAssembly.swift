//
// Created by Arjan Duijzer on 15/03/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import Swinject
import RxSwift

class ViewModelAssembly: Assembly {
    func assemble(container: Container) {
        /// ArticleInteractor
        container.register(ArticleInteractor.self) { r in
                    ArticleInteractor(r.resolve(ArticleRepository.self)!,
                            r.resolve(MediaRepository.self)!)
                }
                .inObjectScope(.container)

    }

    func loaded(resolver: Resolver) {
    }

}
