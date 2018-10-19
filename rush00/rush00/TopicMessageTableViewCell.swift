//
//  TopicMessageTableViewCell.swift
//  rush00
//
//  Created by Danil Vdovenko on 10/7/18.
//  Copyright © 2018 Danil Vdovenko. All rights reserved.
//

import UIKit

class TopicMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var topicMessageAuthor: UILabel!
    @IBOutlet weak var topicMessageDate: UILabel!
    @IBOutlet weak var topicMessageText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
