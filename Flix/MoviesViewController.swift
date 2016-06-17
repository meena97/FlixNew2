//
//  MoviesViewController.swift
//  Flix
//
//  Created by Meena Sengottuvelu on 6/15/16.
//  Copyright © 2016 Meena Sengottuvelu. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var networkErrorView: UIView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var nestedView: UIView!
    
    var movies: [NSDictionary]?
    
    var endpoint: String!
    
    var filtered = [NSDictionary]()
    
    var resultSearchController = UISearchController()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationItem.title = "Movies"
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.setBackgroundImage(UIImage(named: "codepath-logo"), forBarMetrics: .Default)
            navigationBar.tintColor = UIColor(red: 1.0, green: 0.25, blue: 0.25, alpha: 0.8)
            
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
            shadow.shadowOffset = CGSizeMake(2, 2);
            shadow.shadowBlurRadius = 4;
            navigationBar.titleTextAttributes = [
                NSFontAttributeName : UIFont.boldSystemFontOfSize(22),
                NSForegroundColorAttributeName : UIColor(red: 0.5, green: 0.15, blue: 0.15, alpha: 0.8),
                NSShadowAttributeName : shadow
            ]
        }
        
        
        searchBar.delegate = self
        
        networkErrorView.hidden = true
        
        if Reachability.isConnectedToNetwork() == true {
            print("Network OK")
        } else {
            print("No Network Connection")
            networkErrorView.hidden = false
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }

        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        collectionView.insertSubview(refreshControl, atIndex: 0)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        // Do any additional setup after loading the view.
        
        
        let apiKey = "c18d201012e6bed479b73249ead7c8c3"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        
        //Display HUD right before the request is made
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (dataOrNil, response, error) in
                                                                        
         // Hide HUD once the network request comes back (must be done on main UI thread)
         MBProgressHUD.hideHUDForView(self.view, animated: true)
                                                                        
            if let data = dataOrNil {
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData( data, options:[]) as? NSDictionary {
                    
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                                        
                    print("response: \(responseDictionary)")
                    
                    self.movies = responseDictionary["results"] as? [NSDictionary]
                    
                    self.filtered = self.movies!
                    
                    self.collectionView.reloadData()
                    
                    refreshControl.endRefreshing()
                    
                }
            }
            
        })
        
        task.resume()
        
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        let apiKey = "c18d201012e6bed479b73249ead7c8c3"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
                                                                      completionHandler: { (data, response, error) in
                                                                        
         // ... Use the new data to update the data source ... --> what??
                                                                        
         // Reload the tableView now that there is new data
         self.collectionView.reloadData()
                                                                        
         // Tell the refreshControl to stop spinning
         refreshControl.endRefreshing()
                                                                        
        });
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.filtered.removeAll(keepCapacity: false)
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = (self.movies! as NSArray).filteredArrayUsingPredicate(searchPredicate)
        self.filtered = array as! [NSDictionary]
        self.collectionView.reloadData()
        
    }
    
    
    // Return appropriate number of movies
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filtered.count
    }
    
    // Populate collection cell with movie posters
    func collectionView(tableView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = tableView.dequeueReusableCellWithReuseIdentifier("MovieCell",
                                                                    forIndexPath: indexPath) as! CollectionCell
        let movie = filtered[indexPath.row]
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 0.9, green: 0.0, blue: 0.15, alpha: 0.6)
        cell.selectedBackgroundView = backgroundView
        
        
        if let posterPath = movie["poster_path"] as? String {
            let baseUrl = "http://image.tmdb.org/t/p/w500"
            if let imageUrl = NSURL(string: baseUrl + posterPath) {
                let imageRequest = NSURLRequest(URL: imageUrl)
                
                // Fade movie poster in
                cell.moviePic.setImageWithURLRequest(imageRequest, placeholderImage: nil, success: {(imagerequest, imageResponse, image) -> Void in
                    if imageResponse != nil {
                        cell.moviePic.alpha = 0.0
                        cell.moviePic.image = image
                        UIView.animateWithDuration(0.3, animations: {() -> Void in
                            cell.moviePic.alpha = 1.0
                        })
                    } else {
                        cell.moviePic.image = image
                    }},
                                                     failure: nil
                )
            }
        }
        return cell
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filtered = movies!
        } else {
            filtered = movies!.filter({(dataItem: NSDictionary) -> Bool in
                // If dataItem matches the searchText, return true to include it
                let title = dataItem["title"] as! String
                if title.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    return true
                } else {
                    return false
                }
            })
            
        }
        
        
        collectionView.reloadData()
    }
    
    // Show cancel button on searchbar when being used
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.setShowsCancelButton(true, animated: true)
    }

    // Clear search bar when cancel is hit
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        searchBar.text = ""
        filtered = movies!
        collectionView.reloadData()
    }

    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPathForCell(cell)
        let movie = filtered[indexPath!.row]
        
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movie
    
        
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    

}




