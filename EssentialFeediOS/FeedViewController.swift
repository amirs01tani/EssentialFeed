//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Amir on 9/5/23.
//

import Foundation
import UIKit
import EssentialFeed

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}

public class FeedViewController: UITableViewController{
    var feedLoader: FeedLoader!
    private var imageLoader: FeedImageDataLoader?
    private var tableModel = [FeedImage]()
    private var tasks = [IndexPath: FeedImageDataLoaderTask]()
    
    public convenience init(loader: FeedLoader, imageLoader: FeedImageDataLoader) {
        self.init()
        self.feedLoader = loader
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector (load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        feedLoader?.load { [weak self] result in
            switch result {
            case .success(let images):
                self?.tableModel = images
                self?.tableView.reloadData()
            case .failure:
                break
            }
            self?.refreshControl?.endRefreshing()
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = tableModel[indexPath.row]
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = (cellModel.location == nil)
        cell.locationLabel.text = cellModel.location
        cell.descriptionLabel.text = cellModel.description
        cell.feedImageContainer.startShimmering()
        tasks[indexPath] = imageLoader?.loadImageData(from: cellModel.URL) { [weak cell] result in
            cell?.feedImageContainer.stopShimmering()
        }
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellModel = tableModel[indexPath.row]
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
}