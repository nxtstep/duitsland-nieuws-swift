//
// Created by Arjan Duijzer on 08/03/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import Foundation
import OrderedDictionary
import RxSwift

class MediaCache: Cache {
    typealias K = String
    typealias V = Media

    required init(values dict: OrderedDictionary<K, V> = OrderedDictionary<K, V>()) {
        self.cache = SimpleMemCache(values: dict)
    }

    func get(_ id: K) -> Observable<V> {
        return cache.get(id)
    }

    func list(_ page: Int, pageSize size: Int) -> Observable<[V]> {
        return cache.list(page, pageSize: size)
    }

    func listAll() -> Observable<[V]> {
        return cache.listAll()
    }

    func save(_ value: V) -> Observable<V> {
        return cache.save(value)
    }

    func save(_ values: [V]) -> Observable<[V]> {
        return cache.save(values)
    }

    func delete(id: K) -> Observable<V> {
        return cache.delete(id: id)
    }

    func delete(_ value: V) -> Observable<V> {
        return cache.delete(value)
    }

    func deleteAll() -> Observable<[V]> {
        return cache.deleteAll()
    }

    fileprivate let cache: SimpleMemCache<K, V>
}

extension Media: Identifiable {
    var key: String {
        return id
    }
}
