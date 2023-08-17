//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Amir on 8/17/23.
//

import Foundation

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
