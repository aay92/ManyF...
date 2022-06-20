//
//  SpandingModal.swift
//  FirstMany
//
//  Created by Aleksey Alyonin on 12.04.2022.
//

import RealmSwift
import Foundation

class Spending: Object {
    @objc dynamic var category = ""
    @objc dynamic var cost = 1
    @objc dynamic var data = NSData()
}

class Limit: Object {
    @objc dynamic var limitSum = ""
    @objc dynamic var limitDate = NSDate()
    @objc dynamic var lastDay = NSDate()
}

