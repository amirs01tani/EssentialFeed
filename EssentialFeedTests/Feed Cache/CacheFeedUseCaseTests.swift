//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Amir on 8/15/23.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
    
    var store: FeedStore
    private let currentDate: () -> Date
    
//    public enum Error: Swift.Error {
//        case deletionError
//    }
    
    init(store: FeedStore, currentDate: @escaping () -> Date ) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed(completion: { [unowned self] error in
            if error == nil {
                self.store.insertItems(items, timeStamp: self.currentDate(), completion: completion)
            } else {
                completion(error)
            }
        })
    }
}

protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insertItems(_ items: [FeedItem], timeStamp: Date, completion: @escaping DeletionCompletion)
}



final class CacheFeedUseCaseTests: XCTestCase {
    // first thing in recepie is delete the old cache
    // we did not delete the cached feed upon creation
    func test_doesNotMessageStoreOnCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    // request cache deletion on save
    
    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()
        let item = [uniqueItem(), uniqueItem()]
        sut.save(item) { _ in }
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeleteError() {
        let (sut, store) = makeSUT()
        let item = [uniqueItem(), uniqueItem()]
        let deletionError = anyNSError()
        sut.save(item) { _ in }
        store.completeDeletion(with: deletionError)
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    // redundant
    //    func test_save_requestNewCacheInsertionOnsuccessfulDeletion() {
    //        let (sut, store) = makeSUT()
    //        let item = [uniqueItem(), uniqueItem()]
    //        sut.save(item)
    //        store.completeDeletionsuccessfully()
    //        XCTAssertEqual(store.insertCallCount, 1)
    //    }
    
    func test_save_requestNewCacheInsertionWithTimeStampOnsuccessfulDeletion() {
        let timeStamp = Date()
        let (sut, store) = makeSUT(currentDate: { timeStamp })
        let item = [uniqueItem(), uniqueItem()]
        sut.save(item) { _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(item, timeStamp)])
    }
    
    func test_save_failsOnDeletionError() {
        let timeStamp = Date()
        let (sut, store) = makeSUT(currentDate: { timeStamp })
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWithError: deletionError, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: deletionError)
        })
        
    }
    
    func test_save_failsOnInsertionError() {
        let timeStamp = Date()
        let (sut, store) = makeSUT(currentDate: { timeStamp })
        let insertionError = anyNSError()
        
        expect(sut, toCompleteWithError: insertionError, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        })
       
    }
    
    func test_save_succeedsOnSuccessfulCacheInsertion() {
        let timeStamp = Date()
        let (sut, store) = makeSUT(currentDate: { timeStamp })
        
        expect(sut, toCompleteWithError: nil, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        })
        
    }
    
    // Mark: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut: sut, store: store)
    }
    
    private func expect( _ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when
                         action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for save completion")
        var receivedError: Error?
        sut.save([uniqueItem()]) { error in
            receivedError = error
            exp.fulfill()
        }
        action()
        wait (for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
    }
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
    private class FeedStoreSpy: FeedStore {
        
        enum ReceivedMessage: Equatable {
            case deleteCachedFeed
            case insert ([FeedItem], Date)
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
        
        func insertItems(_ items: [FeedItem], timeStamp: Date, completion: @escaping DeletionCompletion) {
            insertionCompletions.append(completion)
            receivedMessages.append(.insert(items, timeStamp))
        }
        
    }
}




