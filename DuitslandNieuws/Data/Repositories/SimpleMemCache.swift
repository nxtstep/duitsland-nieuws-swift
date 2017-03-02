//
// Created by Arjan Duijzer on 15/02/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import Foundation
import RxSwift
import OrderedDictionary

public protocol Identifiable {
    associatedtype K: Hashable

    var key: K { get }
}

public protocol Cache {
    associatedtype K: Hashable
    associatedtype V: Identifiable

    func get(_ id: K) -> Observable<V>

    func list(_ page: Int, pageSize size: Int) -> Observable<[V]>

    func listAll() -> Observable<[V]>

    func save(_ value: V) -> Observable<V>

    func save(_ values: [V]) -> Observable<[V]>

    func delete(id: K) -> Observable<V>

    func delete(_ value: V) -> Observable<V>

    func deleteAll() -> Observable<[V]>
}

public struct SimpleMemCache<K:Hashable, V:Identifiable>: Cache {
    public init(values dict: OrderedDictionary<K, V> = OrderedDictionary<K, V>()) {
        self.cache = AnyMutableWrapper(dict)
    }

    internal func generateKey(_ value: V) -> Observable<K> {
        return Observable.just(value.key as! K)
    }

    public func get(_ id: K) -> Observable<V> {
        return Observable.just(self.cache.value)
                .filter {
                    $0[id] != nil
                }
                .map {
                    $0[id]!
                }
    }

    public func list(_ page: Int, pageSize size: Int) -> Observable<[V]> {
        return Observable.just(self.cache.value)
                .filter {
                    $0.isNotEmpty
                }
                .filter {
                    (page + 1) * size <= $0.count
                }
                .map {
                    $0.orderedValues
                }
                .map {
                    Array($0[(page * size) ..< ((page + 1) * size)])
                }
    }

    public func listAll() -> Observable<[V]> {
        return Observable.just(self.cache.value)
                .filter {
                    $0.isNotEmpty
                }
                .flatMap {
                    Observable.from($0.orderedValues)
                }
                .toArray()
    }

    public func save(_ value: V) -> Observable<V> {
        return generateKey(value)
                .zip(with: Observable.just(value)) {
                    ($0, $1)
                }
                .map { pair in
                    self.cache.value[pair.0] = pair.1
                    return pair.1
                }
    }

    public func save(_ values: [V]) -> Observable<[V]> {
        return Observable.from(values)
                .flatMap {
                    self.save($0)
                }
                .toArray()
    }

    public func delete(id: K) -> Observable<V> {
        return self.get(id)
                .map { _ in
                    self.cache.value.removeValue(forKey: id)!
                }
    }

    public func delete(_ value: V) -> Observable<V> {
        return self.generateKey(value)
                .flatMap {
                    self.delete(id: $0)
                }
    }

    public func deleteAll() -> Observable<[V]> {
        return listAll()
                .flatMap {
                    Observable.from($0)
                }
                .flatMap {
                    self.delete($0)
                }
                .toArray()
    }

    internal func clear() {
        cache.value.removeAll()
    }

    internal let cache: AnyMutableWrapper<OrderedDictionary<K, V>>
}

