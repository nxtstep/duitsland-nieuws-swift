//
// Created by Arjan Duijzer on 15/03/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import Swinject

class RepositoryAssembly: Assembly {

    func assemble(container: Container) {
        /// Repository - Article
        container.register(ArticleRepository.self) { r in
                    ArticleRepository(r.resolve(ArticleCache.self)!, r.resolve(ArticleCloud.self)!)
                }
                .inObjectScope(.container) /// Singleton

        container.register(ArticleCache.self) { _ in
            ArticleCache()
        }

        /// Repository - Media
        container.register(MediaRepository.self) { r in
                    MediaRepository(r.resolve(MediaCache.self)!, r.resolve(MediaCloud.self)!)
                }
                .inObjectScope(.container) /// Singleton
        
        container.register(MediaCache.self) { _ in
            MediaCache()
        }
    }

    func loaded(resolver: Resolver) {
    }

}
