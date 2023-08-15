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
    
    public enum Error: Swift.Error {
        case deletionError
    }
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ item: [FeedItem]) {
        store.deleteCachedFeed(error: { error in
            if error != nil {
                self.store.insertionCachedFeed()
            }
        })
    }
}

class FeedStore {
    var deleteCachedFeedCallCount = 0
    var insertCallCount = 0
    
    func deleteCachedFeed(error: @escaping (Error?)-> ()) {
        deleteCachedFeedCallCount += 1
    }
    
    func completeDeletion(with: Error, index: Int = 0){
        
    }
    
    func insertionCachedFeed() {
        deleteCachedFeedCallCount += 1
    }
}

final class CacheFeedUseCaseTests: XCTestCase {
// first thing in recepie is delete the old cache
// we did not delete the cached feed upon creation
    func test() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
// request cache deletion on save
    
    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()
        let item = [uniqueItem(), uniqueItem()]
        sut.save(item)
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    func test_save_doesNotRequestCacheInsetionOnDeleteError() {
        let (sut, store) = makeSUT()
        let item = [uniqueItem(), uniqueItem()]
        let deletionError = LocalFeedLoader.Error.deletionError
        sut.save(item)
        store.completeDeletion(with: deletionError)
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    // Mark: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut: sut, store: store)
    }
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
}


