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
	func save(graphic: Graphic) throws
}

class GraphicService: Service {
  
  let server = Server()
  
  func load(maxCount: Int) throws -> Graphic {
    var params = [String: Any]()
    params["count"] = maxCount
    params["version"] = "1.1"
    let jsonString = try server.download(from: "https://demo.bankplus.ru/mobws/json/pointsList", post: params)
    let result = try server.handleResult(jsonString: jsonString)
    
    guard let points = result["points"] as? [[String: Any]] else {
      throw Errors.incorrectFormat
    }
    
    return Graphic(dict: points)
  }
  
  
	func save(graphic: Graphic) throws {
		guard let jsonData = try? JSONEncoder().encode(graphic) else {
			throw Errors.saveError
		}
		guard let string = String(data: jsonData, encoding: .utf8) else {
			throw Errors.saveError
		}
		let file = "graphic.txt"
		print(string)

		if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
			let fileURL = dir.appendingPathComponent(file)
			print(fileURL)
			try string.write(to: fileURL, atomically: false, encoding: .utf8)
		}
	}
		

}
