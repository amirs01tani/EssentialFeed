//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Amir on 8/16/23.
//

import Foundation

public class LocalFeedLoader {
    
    public var store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date ) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed(completion: { [weak self] error in
            guard let self = self else { return }
            if error == nil {
                self.store.insertItems(items, timeStamp: self.currentDate(), completion: { [weak self] error in
                    guard self != nil else { return }
                    completion(error)
                })
            } else {
                completion(error)
            }
        })
    }
}
