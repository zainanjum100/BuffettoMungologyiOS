//
//  EpisodeViewCell.swift
//  BuffettoMungology
//
//  Created by Anthonio Ez on 29/03/2018.
//  Copyright © 2018 BuffettoMungology. All rights reserved.
//

import UIKit

class EpisodeViewCell: UITableViewCell {

    public static let cellHeight = CGFloat(70)
    public static let cellIdentifier = "EpisodeViewCell";

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDesc: UILabel!
    @IBOutlet weak var imagePlay: UIImageView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool)
    {
        super.setHighlighted(highlighted, animated: animated)
    
        self.contentView.backgroundColor = highlighted ? UIColor.lightGray.withAlphaComponent(0.25) : UIColor.clear;
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        self.contentView.backgroundColor = selected ? UIColor.lightGray.withAlphaComponent(0.25) : UIColor.clear;
    }
    
    func setData(_ item: EpisodeItem)
    {
        labelTitle.text = item.title
        labelDesc.text = String(format: "%@ %@", Utils.formatByte(item.size), Utils.formatDuration(item.duration / 1000))

        selectionStyle = .none;
    }
    
}
