//
//  CollectionViewCell.swift
//  Vertretungsplan
//
//  Created by Nick Podratz on 28.05.15.
//  Copyright (c) 2015 Nick Podratz. All rights reserved.
//

import UIKit

class OtherAppsCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        imageView.layer.borderWidth = 0.2
        imageView.layer.borderColor = UIColor.darkGrayColor().CGColor
        imageView.layer.cornerRadius = imageView.bounds.width * 0.225
        imageView.layer.masksToBounds = true
    }
}
