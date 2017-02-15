//
//  Observable+ZipWith.swift
//  DuitslandNieuws
//
//  Created by Arjan Duijzer on 28/02/2017.
//  Copyright © 2017 SuperSimple.io. All rights reserved.
//

// PR submitted for this: https://github.com/ReactiveX/RxSwift/pull/1120

import RxSwift

extension ObservableType {

    /**
     Zips `self` with the second observable sequence into one observable sequence by using the selector function whenever all of the observable sequences have produced an element.
     
     - seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)
     
     - parameter resultSelector: Function to invoke for each series of elements at corresponding indexes in the sources.
     - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
     */
    public func zip<O2:ObservableConvertibleType, ResultType>(with second: O2, resultSelector: @escaping (E, O2.E) throws -> ResultType) -> Observable<ResultType> {
        return Observable.zip(asObservable(), second.asObservable(), resultSelector: resultSelector)
    }
}
