//
//  PhotoCollectionTableViewCell.swift
//  Unsplash
//
//  Created by Mathieu Vandeginste on 06/02/2020.
//  Copyright © 2020 matapps. All rights reserved.
//

import UIKit

class PhotoTableViewCell: UITableViewCell {

    @IBOutlet weak var photoCollectionTitleLabel: UILabel!
    @IBOutlet weak var paginationLabel: UILabel!
    @IBOutlet weak var photoCollectionDescriptionLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
}
