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
            case .success(let data, let response):
                if response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) {
                    completion(.success(root.items.map { $0.item }))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
           
        })
    }
  
}

private struct Root: Decodable {
    public let items: [Item]
}

private struct Item: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
    
    var item: FeedItem {
        return FeedItem(id: id, description: description, location: location, imageURL: image)
    }
    
}
