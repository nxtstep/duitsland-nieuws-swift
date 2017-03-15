//
// Created by Arjan Duijzer on 15/03/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import Swinject
import RxMoya

class NetworkAssembly: Assembly {
    func assemble(container: Container) {
        /// Article
        container.register(ArticleCloud.self) { _ in
            ArticleCloud(provider: RxMoyaProvider<ArticleEndpoint>())
        }

        /// Media
        container.register(MediaCloud.self) { _ in
            MediaCloud(provider: RxMoyaProvider<MediaEndpoint>())
        }
    }

    func loaded(resolver: Resolver) {
    }

}
