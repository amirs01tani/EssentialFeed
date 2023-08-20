//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Amir on 8/20/23.
//

import XCTest
import EssentialFeed

final class ValidateFeedCacheUseCaseTests: XCTestCase {

    func test_doesNotMessageStoreOnCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_valicateCache_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT ()
        sut.validateCache()
        store.completeRetrieval(with: anyNSError() )
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_valicateCache_doesNotDeletesCacheOnEmptyCache() {
        let (sut, store) = makeSUT ()
        sut.validateCache()
        store.completeRetrievalWithEmptyCache()
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_valicateCache_doesNotDeleteCacheOnNonExpiredCacheCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT (currentDate: { fixedCurrentDate })
        sut.load { _ in }
        store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)
        XCTAssertEqual (store.receivedMessages, [.retrieve])
    }
    
    func test_valicateCache_deletesOnCacheExpiration() {
        let feed = uniqueImageFeed ()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT (currentDate: { fixedCurrentDate })
        sut.validateCache()
        
        store.completeRetrieval(with: feed.local, timestamp: expirationTimestamp)
        XCTAssertEqual (store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_valicateCache_deletesExpiredCache() {
        let feed = uniqueImageFeed ()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT (currentDate: { fixedCurrentDate })
        sut.validateCache()
        store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
        XCTAssertEqual (store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_valicateCache_doesNotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader (store: store, currentDate: Date.init)
        let receivedResults = [LocalFeedLoader.LoadResult]()
        
        sut?.validateCache()
        sut = nil
        store.completeRetrieval(with: anyNSError())
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut: sut, store: store)
    }

}
