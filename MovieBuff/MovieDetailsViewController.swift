//
//  MovieDetailsViewController.swift
//  MovieBuff
//
//  Created by Chintan Rita on 9/11/15.
//  Copyright © 2015 Chintan Rita. All rights reserved.
//

import UIKit
import AFNetworking

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var posterView: UIImageView!

    var movie: NSDictionary = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let title = movie["title"] as? String {
            self.navigationItem.title = title
        }
        if let description = movie["synopsis"] as? String {
            self.descriptionTextView.text = description
        }
        if let images = movie["posters"] as? NSDictionary {
            if let detailedUrl = images["detailed"] as? String {
                let photoUrl = NSURL(string:detailedUrl)!
                self.posterView.setImageWithURL(photoUrl)
            }
        }
        loadHighResImage()
    }
    
    func loadHighResImage() {
        if let alernateIds = movie["alternate_ids"] as? NSDictionary {
            if let imdbId = alernateIds["imdb"] as? String {
                let url = NSURL(string: "http://www.omdbapi.com/?i=tt\(imdbId)&plot=full&r=json")
                
                let request = NSURLRequest(URL: url!)
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
                    let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                    if let poster = responseDictionary["Poster"] as? String {
                        let posterURL = NSURL(string: poster)
                        self.posterView.setImageWithURL(posterURL!)
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setSelectedMovie(movie:NSDictionary) {
        self.movie = movie
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
