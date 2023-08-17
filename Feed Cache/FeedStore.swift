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
    func insertItems(_ items: [LocalFeedItem], timeStamp: Date, completion: @escaping DeletionCompletion)
}
