//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Amir on 8/7/23.
//

import Foundation

public class RemoteFeedLoader: FeedLoader {
    
    private var url: URL
    private var client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = LoadFeedResult
    
    public init(url: URL ,client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (LoadFeedResult) -> Void) {
        client.get(from: url, completion: { [weak self] result in
            guard let _ = self else { return }
            switch result {
            case .success(let data, let response):
                completion(RemoteFeedLoader.map(data: data, response: response))
            case .failure:
                completion(.failure(RemoteFeedLoader.Error.connectivity))
            }
           
        })
    }
    
    private static func map(data: Data, response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemMapper.map(data, from: response)
            return .success(items.toModels())
        } catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedItem] {
        return map { FeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.image) }
    }
}
