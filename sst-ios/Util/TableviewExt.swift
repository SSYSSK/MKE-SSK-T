//
//  TableviewExt.swift
//  sst-ios
//
//  Created by Zal Zhang on 1/14/17.
//  Copyright © 2017 ios. All rights reserved.
//

import UIKit

extension UITableView {
    func dequeueCell<T: UITableViewCell>(_ cell: T.Type) -> T? {
        if let cell = dequeueReusableCell(withIdentifier: "\(T.classForCoder())") {
            return cell as? T
        }
        return nil
    }
}
