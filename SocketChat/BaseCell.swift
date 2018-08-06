//
//  BaseCell.swift
//  SocketChat
//
//  Created by Gabriel Theodoropoulos on 1/31/16.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit

class BaseCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        separatorInset = .zero
        preservesSuperviewLayoutMargins = false
        layoutMargins = .zero
        layoutIfNeeded()
        
        // Set the selection style to None.
        selectionStyle = .none
    }
}
