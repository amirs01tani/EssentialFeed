//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Amir on 8/15/23.
//

import XCTest
import EssentialFeed

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
        let items = [uniqueImage(), uniqueImage()]
        sut.save(items) { _ in }
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeleteError() {
        let (sut, store) = makeSUT()
        let items = [uniqueImage(), uniqueImage()]
        let deletionError = anyNSError()
        sut.save(items) { _ in }
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
        let item = [uniqueImage(), uniqueImage()]
        let localItems = item.toLocal()
        sut.save(item) { _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(localItems, timeStamp)])
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
    
    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader (store: store, currentDate: Date.init)
        var receivedResults = [Error?]()
        sut?.save([uniqueImage()]) { receivedResults.append($0) }
        sut = nil
        store.completeDeletion(with: anyNSError ())
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader (store: store, currentDate: Date.init)
        var receivedResults = [Error?]()
        sut?.save([uniqueImage()]) { receivedResults.append($0) }
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())
        XCTAssertTrue(receivedResults.isEmpty)
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
        sut.save([uniqueImage()]) { error in
            receivedError = error
            exp.fulfill()
        }
        action()
        wait (for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
    }
    
    private func uniqueImage() -> FeedImage {
        return FeedImage(id: UUID(), description: "any", location: "any", URL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
}




