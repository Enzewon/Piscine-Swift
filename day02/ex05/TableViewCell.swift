//
//  TableViewCell.swift
//  ex05
//
//  Created by Danil Vdovenko on 10/3/18.
//  Copyright © 2018 Danil Vdovenko. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var personName: UILabel!
    @IBOutlet weak var personDescription: UILabel!
    @IBOutlet weak var personDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
