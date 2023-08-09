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

public class RemoteFeedLoader {
    
    private var url: URL
    private var client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
    }
    
    public init(url: URL ,client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Error) -> Void = { _ in }) {
        client.get(from: url, completion: { error in
            completion(.connectivity)
        })
    }
  
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error) -> Void)
}
