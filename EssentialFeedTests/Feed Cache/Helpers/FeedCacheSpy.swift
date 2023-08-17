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
        case retrieve
    }
    private (set) var receivedMessages = [ReceivedMessage]()
    
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    private var retrievalCompletions = [RetrievalCompletion]()
    
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
    
    func completeRetrieval(with error: Error, index: Int = 0) {
        retrievalCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func completeInsertionSuccessfully(index: Int = 0) {
        insertionCompletions[index](nil)
    }
    
//    func completeRetrievalSuccessfully(with data: [LocalFeedImage], index: Int = 0) {
//        retrievalCompletions[index](data, nil)
//    }
    
    func completeRetrievalWithEmptyCache(index: Int = 0) {
        retrievalCompletions[index](nil)
    }
    
    func insertItems(_ items: [LocalFeedImage], timeStamp: Date, completion: @escaping DeletionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(items, timeStamp))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        retrievalCompletions.append(completion)
        receivedMessages.append(.retrieve)
    }
    
}
