//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Amir on 8/16/23.
//

import Foundation

final public class LocalFeedLoader {
    
    public var store: FeedStore
    private let currentDate: () -> Date
    private let calendar = Calendar(identifier: .gregorian)
    
    public init(store: FeedStore, currentDate: @escaping () -> Date ) {
        self.store = store
        self.currentDate = currentDate
    }
    
    private var maxCachedBufferInDays: Int {
        return 7
    }
    // validations are better to be in domain model to be reusable
    private func validate(_ timestamp: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCachedBufferInDays, to: timestamp) else {
            return false
        }
        return currentDate() < maxCacheAge
    }
}
 
extension LocalFeedLoader {
    public typealias SaveResult = Error?
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed(completion: { [weak self] error in
            guard let self = self else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(feed, with: completion)
            }
        })
    }
    
    private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insertItems(feed.toLocal(), timeStamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

extension LocalFeedLoader {
    public func validateCache () {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                self.store.deleteCachedFeed { _ in }
            case let .found(_, timestamp) where !self.validate(timestamp):
                self.store.deleteCachedFeed { _ in }
            case .found, .empty:
                break
            }
        }
    }

}
    
extension LocalFeedLoader: FeedLoader {
    
    public typealias LoadResult = LoadFeedResult
    public func load(with completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                completion(.failure(error))
                
            case let .found(feed, timestamp) where self.validate(timestamp):
                completion(.success(feed.toModels()))
            case .found, .empty:
                completion(.success([]))
                // or fallThrough
            }
        }
    }
}


public extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, URL: $0.URL)}
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, URL: $0.URL) }
    }
}
