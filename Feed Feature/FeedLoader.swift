//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Amir on 8/7/23.
//

import Foundation

public class RemoteFeedLoader {
    
    private var url: URL
    private var client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL ,client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (RemoteFeedLoader.Result) -> Void) {
        client.get(from: url, completion: { [weak self] result in
            guard let _ = self else { return }
            switch result {
            case .success(let data, let response):
                completion(FeedItemMapper.map(data, from: response))
            case .failure:
                completion(.failure(.connectivity))
            }
           
        })
    }
}
