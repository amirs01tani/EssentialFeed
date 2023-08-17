//
//  FeedCacheSpy.swift
//  EssentialFeedTests
//
//  Created by Amir on 8/17/23.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
    
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert ([LocalFeedImage], Date)
    }
    private (set) var receivedMessages = [ReceivedMessage]()
    
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func completeDeletion(with error: Error, index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeInsertion(with error: Error, index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func completeInsertionSuccessfully(index: Int = 0) {
        insertionCompletions[index](nil)
    }
    
    func insertItems(_ items: [LocalFeedImage], timeStamp: Date, completion: @escaping DeletionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(items, timeStamp))
    }
    
}
