//
//  MyTableViewCell.swift
//  ImageLibrary
//
//  Created by Ganpat Jangir on 02/11/22.
//

import UIKit

class MyTableViewCell: UITableViewCell {
    
    @IBOutlet var myImage : UIImageView!
    
    static let identifier = "MyTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil);
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
