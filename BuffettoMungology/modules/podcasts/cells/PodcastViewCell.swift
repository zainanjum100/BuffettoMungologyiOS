//
//  PodcastViewCell.swift
//  BuffettoMungology
//
//  Created by Anthonio Ez on 03/05/2019.
//  Copyright © 2019 BuffettoMungology. All rights reserved.
//

import UIKit
import SDWebImage

class PodcastViewCell: UICollectionViewCell {

    public static var cellIdentifier = "PodcastViewCell"

    @IBOutlet weak var imagePodcast: UIImageView!
    
  
    
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        
    }

    func setData(_ data: PodcastItem)
    {
        let url = (App.cloudUrl + "/" + data.folder + "/" + data.image).replacingOccurrences(of: " ", with: "%20")
        
        imagePodcast.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "logo.png"), options: SDWebImageOptions.init(rawValue: 0), completed: nil)
        
    
    }
}
