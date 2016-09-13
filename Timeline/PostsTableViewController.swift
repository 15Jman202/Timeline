//
//  PostsTableViewController.swift
//  Timeline
//
//  Created by Justin Carver on 9/12/16.
//  Copyright © 2016 Justin Carver. All rights reserved.
//

import UIKit

class PostsTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var Posts: [Post] = []
    
    var searchController = UISearchController?()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func setupSearchController() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let resultsController = storyboard.instantiateViewControllerWithIdentifier("resultsTVC")
        
        searchController = UISearchController(searchResultsController: resultsController)
        
        guard let searchController = searchController else { return }
        
        searchController.searchBar.placeholder = "Search Posts"
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.definesPresentationContext = true
        searchController.searchResultsUpdater = self
        
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Posts.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("postCell", forIndexPath: indexPath) as? PostCell
        
        let post = Posts[indexPath.row]
        cell?.PostImage.image = post.photo
        
        return cell ?? PostCell()
    }
    
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let indexpath = tableView.indexPathForSelectedRow else { return }
        let post = Posts[indexpath.row]
        let destinationVC = segue.destinationViewController as? PostDetailTableViewController
        destinationVC?.post = post
    }
}




