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
    var animated = true
    var originalOrigin = CGRect().origin
    var originalSize = CGRect().size

    var movie: NSDictionary = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        originalOrigin = self.descriptionTextView.frame.origin
        originalSize = self.descriptionTextView.frame.size
        let aSelector = Selector("animateTextView")
        
        let _tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: aSelector)
        
        self.descriptionTextView.addGestureRecognizer(_tapGesture)
        
        // Do any additional setup after loading the view.
        addTitle()
        addDescription()
        loadLowResImage()
        loadHighResImage()
    }
    
    func animateTextView() {
        if (animated) {
            UIView.animateWithDuration(1.0, animations: {
                self.descriptionTextView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            })
        }
        else {
            UIView.animateWithDuration(1.0, animations: {
                self.descriptionTextView.frame = CGRect(x: self.originalOrigin.x, y: self.originalOrigin.y, width: self.originalSize.width, height: self.originalSize.height)
            })
        }
        animated = !animated
    }
    
    func addTitle() {
        if let title = movie["title"] as? String {
            self.navigationItem.title = title
        }
    }
    
    func addDescription() {
        var description:String = ""
        
        if let year = movie["year"] as? Int {
            description += "Year: \(year)\n"
        }
        
        if let rating = movie["mpaa_rating"] as? String {
            description += "Rating: \(rating)\n"
        }
        
        if let reviews = movie["ratings"] as? NSDictionary {
            if let criticsRating = reviews["critics_rating"] as? NSString {
                description += "Critics Ratings: \(criticsRating)\n"
            }
            
            if let audienceRating = reviews["audience_rating"] as? NSString {
                description += "Audience Ratings: \(audienceRating)\n"
            }
        }
        
        if let synopsis = movie["synopsis"] as? String {
            description += "\n\(synopsis)"
        }
        self.descriptionTextView.text = description
    }
    
    func loadLowResImage() {
        if let images = movie["posters"] as? NSDictionary {
            if let detailedUrl = images["detailed"] as? String {
                let photoUrl = NSURL(string:detailedUrl)!
                self.posterView.setImageWithURL(photoUrl)
            }
        }
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
                        let request = NSURLRequest(URL: posterURL!)
                        self.posterView.alpha = 0
                        self.posterView.setImageWithURLRequest(request, placeholderImage: nil, success: { (req, response, image) -> Void in
                            self.posterView.image = image
                            UIView.animateWithDuration(1, animations: { () -> Void in
                                self.posterView.alpha = 1;
                                
                            })
                            }, failure: { (req, response, err) -> Void in
                                NSLog("ERROR \(err)")
                            }
                        )
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
