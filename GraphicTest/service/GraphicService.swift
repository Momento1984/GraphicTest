//
//  GraphicService.swift
//  GhaphicTest
//
//  Created by Виталий Антипов on 23.06.2018.
//  Copyright © 2018 Виталий Антипов. All rights reserved.
//

import Foundation

protocol Service {
  func load(maxCount: Int) throws -> Graphic
  func save()
}

class GraphicService: Service {
  
  let server = Server()
  
  func load(maxCount: Int) throws -> Graphic {
    var params = [String: Any]()
    params["count"] = 5
    params["version"] = "1.1"
    let jsonString = try server.download(from: "https://demo.bankplus.ru/mobws/json/pointsList", post: params)
    let result = try server.handleResult(jsonString: jsonString)
    
    guard let points = result["points"] as? [[String: Any]] else {
      throw Server.ServerError.incorrectFormat
    }
    
    

    //JSONDecoder().decode(Graphic.self, from: <#T##Data#>)
    return Graphic(dict: points)
  }
  
  
  func save() {
    
  }
}
