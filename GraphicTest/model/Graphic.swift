//
//  Ghaphic.swift
//  GhaphicTest
//
//  Created by Виталий Антипов on 23.06.2018.
//  Copyright © 2018 Виталий Антипов. All rights reserved.
//

import UIKit

struct Graphic: Codable {
  
	
  let points: [CGPoint]
  
  init(dict: [[String: Any]]) {
    points = dict.map { CGPoint(dict: $0) }.sorted { $0.x < $1.x }
  }
}

extension CGPoint {
  init(dict: [String: Any]) {
    let strX = dict["x"] as! String
    let strY = dict["y"] as! String

    self.init()
    self.x = CGFloat(Double(strX)!)
    self.y = CGFloat(Double(strY)!)
  }
}
