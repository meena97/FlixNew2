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

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UICollectionViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var errorView: UIView!
    
    var movies: [NSDictionary]?
    
    var endpoint: String!
    
    var filtered = [NSDictionary]()
    var resultSearchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorView.hidden = true
        
        if Reachability.isConnectedToNetwork() == true {
            print("Network OK")
        } else {
            print("No Network Connection")
            errorView.hidden = false
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }
        
        self.resultSearchController = UISearchController(searchResultsController: nil)
        self.resultSearchController.searchResultsUpdater = self
        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.resultSearchController.searchBar.sizeToFit()
        
        self.tableView.tableHeaderView = self.resultSearchController.searchBar
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        tableView.dataSource = self
        tableView.delegate = self
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
                    
                    print("response: \(responseDictionary)")
                    
                    self.movies = responseDictionary["results"] as! [NSDictionary]
                    
                    self.tableView.reloadData()
                    
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
         self.tableView.reloadData()
                                                                        
         // Tell the refreshControl to stop spinning
         refreshControl.endRefreshing()
                                                                        
        });
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            
            if self.resultSearchController.active {
                return self.filtered.count
            } else {
                return self.movies!.count
            }
            
            //return movies.count
        } else {
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
//        let movie = movies![indexPath.row]
//        let title = movie["title"] as! String
//        let overview = movie["overview"] as! String
//        let posterPath = movie["poster_path"] as! String
//        
//        let baseURL = "http://image.tmdb.org/t/p/w500"
//        let imageURL = NSURL(string: baseURL + posterPath)
        
//        cell.titleLabel.text = title
//        cell.overviewLabel.text = overview
//        cell.posterView.setImageWithURL(imageURL!)
//        
//        print("row \(indexPath.row)")
        
        
        if(self.resultSearchController.active) {
            
            let movie = self.filtered[indexPath.row]
            let title = movie["title"] as! String
            let overview = movie["overview"] as! String
            let posterPath = movie["poster_path"] as! String
            
            let baseURL = "http://image.tmdb.org/t/p/w500"
            let imageURL = NSURL(string: baseURL + posterPath)
            
            cell.titleLabel.text = title
            cell.overviewLabel.text = overview
            cell.posterView.setImageWithURL(imageURL!)
            
            print("row \(indexPath.row)")
        } else {
            let movie = self.movies![indexPath.row]
            let title = movie["title"] as! String
            let overview = movie["overview"] as! String
            let posterPath = movie["poster_path"] as! String
            
            let baseURL = "http://image.tmdb.org/t/p/w500"
            let imageURL = NSURL(string: baseURL + posterPath)
            
            cell.titleLabel.text = title
            cell.overviewLabel.text = overview
            cell.posterView.setImageWithURL(imageURL!)
        }
        
        return cell
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.filtered.removeAll(keepCapacity: false)
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = (self.movies! as NSArray).filteredArrayUsingPredicate(searchPredicate)
        self.filtered = array as! [NSDictionary]
        self.tableView.reloadData()
        
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movie
        
        
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}

// MARK: - UICollectionViewDataSource
extension MoviesViewController: UICollectionViewDataSource {
    // Return appropriate number of movies
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filtered.count
    }
    
    // Populate collection cell with movie posters
    func collectionView(tableView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = tableView.dequeueReusableCellWithReuseIdentifier("codepath.MovieCollectionCell",
                                                                         forIndexPath: indexPath) as! CollectionCell
        let movie = filtered[indexPath.row]
        
        //cell.titleLabel.text = title
        //cell.overviewLabel.text = overview
        //cell.moviePoster.setImageWithURL(imageUrl!)
        
        if let posterPath = movie["poster_path"] as? String {
            let baseUrl = "http://image.tmdb.org/t/p/w500"
            if let imageUrl = NSURL(string: baseUrl + posterPath) {
                let imageRequest = NSURLRequest(URL: imageUrl)
                
                // Fade movie poster in
//                cell.posterView.setImageWithURLRequest(imageRequest, placeholderImage: nil, success: {(imagerequest, imageResponse, image) -> Void in
//                    if imageResponse != nil {
//                        cell.moviePoster.alpha = 0.0
//                        cell.moviePoster.image = image
//                        UIView.animateWithDuration(0.3, animations: {() -> Void in
//                            cell.moviePoster.alpha = 1.0
//                        })
//                    } else {
//                        cell.moviePoster.image = image
//                    }},
//                                                        failure: nil
//                )
            }
        }
        return cell
    }
}


