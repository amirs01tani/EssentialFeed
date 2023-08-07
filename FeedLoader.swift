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
