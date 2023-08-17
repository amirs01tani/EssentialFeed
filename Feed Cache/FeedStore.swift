//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Amir on 8/16/23.
//

import Foundation

public enum RetrieveCachedFeedResult {
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
    case failure(Error)
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrieveCachedFeedResult) -> Void
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insertItems(_ feed: [LocalFeedImage], timeStamp: Date, completion: @escaping DeletionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
