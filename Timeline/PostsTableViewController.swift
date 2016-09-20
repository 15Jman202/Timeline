//
//  PostsTableViewController.swift
//  Timeline
//
//  Created by Justin Carver on 9/12/16.
//  Copyright © 2016 Justin Carver. All rights reserved.
//

import UIKit

class PostsTableViewController: UITableViewController, UISearchResultsUpdating {
    
    // MARK: - View
    
    var searchController = UISearchController?()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        tryFullSync()
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: #selector(postsChanged(_: )), name: PostController.postChangedNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func tryFullSync(completion: (() -> Void)? = nil) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        PostController.sharedController.preformFullSync {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if let completion = completion {
                completion()
            }
        }
    }

    @IBAction func refreshRequested(sender: UIRefreshControl) {
        tryFullSync {
            self.refreshControl?.endRefreshing()
        }
    }

    // MARK: - Search Controller
    
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

    func postsChanged(notification: NSNotification) {
        tableView.reloadData()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard let text = searchController.searchBar.text, resultsController = searchController.searchResultsController as? SearchResultsTableViewController else { return }
        resultsController.resultsArray = PostController.sharedController.posts.filter {$0.matchesSearchTerm(text)}.map {($0 as SearchableRecord)}
        resultsController.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PostController.sharedController.posts.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("postCell", forIndexPath: indexPath) as? PostCell
        
        let post = PostController.sharedController.posts[indexPath.row]
        cell?.PostImage.image = post.photo
        
        return cell ?? PostCell()
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toDetailView" {
            guard let indexpath = tableView.indexPathForSelectedRow else { return }
            let post = PostController.sharedController.posts[indexpath.row]
            let destinationVC = segue.destinationViewController as? PostDetailTableViewController
            destinationVC?.post = post
        }
        
        if segue.identifier == "toDetailFromSearch" {
            
            if let detailViewController = segue.destinationViewController as? PostDetailTableViewController,
                let sender = sender as? SearchCell,
                let selectedIndexPath = (searchController?.searchResultsController as? SearchResultsTableViewController)?.tableView.indexPathForCell(sender),
                let searchTerm = searchController?.searchBar.text?.lowercaseString {
                
                let posts = PostController.sharedController.posts.filter({ $0.matchesSearchTerm(searchTerm) })
                let post = posts[selectedIndexPath.row]
                
                detailViewController.post = post
            }
        }
    }
}


