//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Amir on 8/16/23.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insertItems(_ feed: [LocalFeedImage], timeStamp: Date, completion: @escaping DeletionCompletion)
    func retrieve()
}
