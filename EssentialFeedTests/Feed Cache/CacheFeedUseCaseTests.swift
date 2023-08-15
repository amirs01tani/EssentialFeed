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
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ item: [FeedItem]) {
        store.deleteCachedFeed()
    }
}

class FeedStore {
    var deleteCachedFeedCallCount = 0
    
    func deleteCachedFeed() {
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
    
    // Mark: - Helpers
    
    private func makeSUT() -> (sut: LocalFeedLoader, store: FeedStore){
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        return (sut: sut, store: store)
    }
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
}


