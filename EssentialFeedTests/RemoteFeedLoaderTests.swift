//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Amir on 8/8/23.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.get(from: URL(string: "https://a-url.com")!)
    }
}

class HTTPClient {
    static var shared = HTTPClient()
    func get(from url: URL) {}
}

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
    
    override func get(from url: URL) {
        requestedURL = url
    }
}

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let sut = RemoteFeedLoader()
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let sut = RemoteFeedLoader()
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
        
    }
    
    

}
