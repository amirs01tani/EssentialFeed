//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Amir on 8/8/23.
//

import XCTest

class RemoteFeedLoader {
    var url: URL
    var client: HTTPClient
    
    internal init(url: URL ,client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    func load() {
        client.get(from: url)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT(client: HTTPClientSpy())
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let (sut, client) = makeSUT(url: URL(string: "https://a-given-url.com")!, client: HTTPClientSpy())
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, sut.url)
        
    }
    
    // MARK - Helpers
    
    func makeSUT(url: URL = URL(string: "https://a-url.com")!, client: HTTPClient) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut: sut, client: client)
    }
    
    class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
        
        func get(from url: URL) {
            requestedURL = url
        }
    }

}
