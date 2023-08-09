//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Amir on 8/7/23.
//

import Foundation

//protocol FeedLoader {
//    func load(completion: @escaping () -> Result<[FeedItem], Error>)
//}

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

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
        client.get(from: url, completion: { result in
            switch result {
            case .success(let data, _):
                if let _ = try? JSONSerialization.jsonObject(with: data) {
                    completion(.success([]))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
           
        })
    }
  
}
