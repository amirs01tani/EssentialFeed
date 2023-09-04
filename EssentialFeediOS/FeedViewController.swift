//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Amir on 9/5/23.
//

import Foundation
import UIKit
import EssentialFeed

public class FeedViewController: UITableViewController{
    var loader: FeedLoader!
    
    public convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector (load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader.load(with: { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        })
    }
}
