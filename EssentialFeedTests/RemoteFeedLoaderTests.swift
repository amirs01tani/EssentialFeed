//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Amir on 8/8/23.
//

import XCTest

class RemoteFeedLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let sut = RemoteFeedLoader()
        let client = HTTPClient()

        XCTAssertNil(client.requestedURL)
    }

}
