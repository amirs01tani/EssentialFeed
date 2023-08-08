//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Amir on 8/7/23.
//

import Foundation

protocol FeedLoader {
    func load(completion: @escaping () -> Result<[FeedItem], Error>)
}

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
