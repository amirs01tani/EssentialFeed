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
    private var tableModel = [FeedImage]()
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
        loader?.load { [weak self] result in
            switch result {
            case .success(let images):
                self?.tableModel = images
                self?.tableView.reloadData()
                self?.refreshControl?.endRefreshing()
            case .failure:
                break
            }
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
        return cell
    }
}
