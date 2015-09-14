//
//  MovieListCell.swift
//  MovieBuff
//
//  Created by Chintan Rita on 9/11/15.
//  Copyright © 2015 Chintan Rita. All rights reserved.
//

import UIKit

class MovieListCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var posterView: UIImageView!
    var originalColor: UIColor!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        originalColor = titleLabel.textColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        if (selected) {
            self.backgroundColor = originalColor
            titleLabel.textColor = UIColor.blackColor()
            descriptionLabel.textColor = UIColor.blackColor()
        } else {
            titleLabel.textColor = originalColor
            descriptionLabel.textColor = originalColor
            self.backgroundColor = UIColor.blackColor()
        }
    }

}
