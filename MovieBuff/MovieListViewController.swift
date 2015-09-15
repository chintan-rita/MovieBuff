//
//  MovieListViewController.swift
//  MovieBuff
//
//  Created by Chintan Rita on 9/11/15.
//  Copyright © 2015 Chintan Rita. All rights reserved.
//

import UIKit
import AFNetworking
import JTProgressHUD

class   MovieListViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate {
    var refreshControl: UIRefreshControl!

    @IBOutlet weak var networkErrorDescriptionLabel: UILabel!
    @IBOutlet weak var searchField: UISearchBar!
    @IBOutlet weak var networkErrorTitleLabel: UILabel!
    @IBOutlet weak var movieTableView: UITableView!
    
    var movies = []
    var allMovies = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        makeNetworkRequest()
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        
        self.movieTableView.insertSubview(refreshControl, atIndex: 0)
        searchField.delegate = self
    }
    
    func searchBar(_searchBar: UISearchBar,
        textDidChange searchText: String) {
            if (searchText.isEmpty) {
                self.movies = self.allMovies
            }
            else {
                self.movies = self.allMovies.filter({ (movie) -> Bool in
                    if let title = movie["title"] as? String {
                        return title.containsString(searchText)
                    }
                    return false
                })
            }
            self.movieTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.movies = self.allMovies
        self.movieTableView.reloadData()
        self.searchField.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchField.resignFirstResponder()
    }
    
    func onRefresh() {
        JTProgressHUD.show()
        makeNetworkRequest()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        // do something here
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("com.MovieListCell", forIndexPath: indexPath) as! MovieListCell
        
        if let movie = movies[indexPath.row] as? NSDictionary {
            if let title = movie["title"] as? String {
                cell.titleLabel.text = title
            }

            if let synopsis = movie["synopsis"] as? String {
                cell.descriptionLabel.text = synopsis
            }
            
            if let images = movie["posters"] as? NSDictionary {
                if let detailedUrl = images["detailed"] as? String {
                    let photoUrl = NSURL(string:detailedUrl)!
                    let request = NSURLRequest(URL: photoUrl)
                    cell.posterView.setImageWithURLRequest(request, placeholderImage: nil, success: { (req, response, image) -> Void in
                        cell.posterView.image = image
                        UIView.animateWithDuration(1, animations: { () -> Void in
                            cell.posterView.alpha = 1
                        })
                        }, failure: { (req, response, err) -> Void in
                        }
                    )
                }
            }
        }
        
        return cell
    }
    
    func hideNetworkErrorLabel() {
        networkErrorDescriptionLabel.alpha = 0
        networkErrorTitleLabel.alpha = 0
    }
    
    func showNetworkErrorLabel() {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.networkErrorDescriptionLabel.alpha = 1
            self.networkErrorTitleLabel.alpha = 1
        })
    }
    
    func newShuffledArray(array:NSArray) -> NSArray {
        let mutableArray = array.mutableCopy() as! NSMutableArray
        let count = mutableArray.count
        if count>1 {
            for var i=count-1;i>0;--i{
                mutableArray.exchangeObjectAtIndex(i, withObjectAtIndex: Int(arc4random_uniform(UInt32(i+1))))
            }
        }
        return mutableArray as NSArray
    }
    
    func makeNetworkRequest() {
        JTProgressHUD.show()

        hideNetworkErrorLabel()
        let clientId = "f2fk8pundhpxf77fscxvkupy"
        
        let url = NSURL(string: "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/in_theaters.json?apiKey=\(clientId)")!
        let request = NSURLRequest(URL: url)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            JTProgressHUD.hide()
            self.refreshControl.endRefreshing()
            if (error != nil) {
                self.showNetworkErrorLabel()
            }
            else {
                let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
            
            
                self.movies = responseDictionary["movies"] as! NSArray
                self.movies = self.newShuffledArray(self.movies)
                self.allMovies = self.movies
            
                self.movieTableView.reloadData()
            }
            
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        self.searchField.resignFirstResponder()
        
        let vc = segue.destinationViewController as! MovieDetailsViewController
        let indexPath = movieTableView.indexPathForCell(sender as! UITableViewCell)
        
        if let movie = self.movies[indexPath!.item] as? NSDictionary {
            vc.setSelectedMovie(movie)
        }
        
        
        
    }

}
