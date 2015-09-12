//
//  MovieListViewController.swift
//  MovieBuff
//
//  Created by Chintan Rita on 9/11/15.
//  Copyright © 2015 Chintan Rita. All rights reserved.
//

import UIKit
import AFNetworking

class MovieListViewController: UIViewController, UITableViewDataSource {
    var refreshControl: UIRefreshControl!

    @IBOutlet weak var movieTableView: UITableView!
    var movies = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        makeNetworkRequest()
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        
        self.movieTableView.insertSubview(refreshControl, atIndex: 0)
        
        
    }
    
    func onRefresh() {
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
                    cell.posterView.setImageWithURL(photoUrl)
                }
            }
        }
        
        return cell
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
        let clientId = "f2fk8pundhpxf77fscxvkupy"
        
        let url = NSURL(string: "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/in_theaters.json?apiKey=\(clientId)")!
        let request = NSURLRequest(URL: url)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
            
            
            self.movies = responseDictionary["movies"] as! NSArray
            self.movies = self.newShuffledArray(self.movies)
            
            self.movieTableView.reloadData()
            self.refreshControl.endRefreshing()
            
            
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let vc = segue.destinationViewController as! MovieDetailsViewController
        let indexPath = movieTableView.indexPathForCell(sender as! UITableViewCell)
        
        if let movie = self.movies[indexPath!.item] as? NSDictionary {
            vc.setSelectedMovie(movie)
        }
        
        
        
    }

}
