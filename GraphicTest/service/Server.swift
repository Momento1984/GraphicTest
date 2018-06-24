//
//  Server.swift
//  GhaphicTest
//
//  Created by Виталий Антипов on 23.06.2018.
//  Copyright © 2018 Виталий Антипов. All rights reserved.
//

import Foundation

class Server: NSObject, URLSessionDelegate {
  
  enum ServerError: Error {
    case invalidURL
    case httpError(code: Int, message: String)
    case custom(message: String)
    case incorrectFormat

  }
  
  typealias Params = [String: Any]
  func download(from url: String, post: Params) throws -> String {
    
    data = nil
    error = nil
    response = nil
    
    guard let url = URL(string: url) else {
      throw ServerError.invalidURL
    }
    var request = URLRequest(url: url)
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    request.httpMethod = "POST"
    let postString = body(from: post)
    request.httpBody = postString.data(using: .utf8)
    let queue = OperationQueue()
    let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: queue)
    
    let semaphore = DispatchSemaphore(value: 0)
    let task = session.dataTask(with: request) { data, response, error in
      self.data = data
      self.response = response
      self.error = error
      semaphore.signal()
    }
    task.resume()
    semaphore.wait()
    
    return try handleResponse()
  }
  
  func urlSession(_: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
  }
  
  private func body(from params: Params) -> String {
    return params.reduce(into: "") { res, pair in
      res += "\(pair.key)=\(pair.value)&"
    }
  }
  
  private func handleResponse() throws -> String {
    guard let data = data, error == nil else {
      print("error=\(String(describing: error))")
      throw ServerError.httpError(code: 333, message: error?.localizedDescription ?? "Ошибка сервера. Попробуйте повторить позже")
    }
    
    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
      print("statusCode should be 200, but is \(httpStatus.statusCode)")
      print("response = \(String(describing: response))")
      throw ServerError.httpError(code: httpStatus.statusCode, message: "Ошибка сервера. Попробуйте повторить позже")
    }
    
    guard let responseString = String(data: data, encoding: .utf8) else {
      throw ServerError.custom(message: "Не удалось распознать ответ")
    }
    print("responseString = \(String(describing: responseString))")
    return responseString

  }
  
  func handleResult(jsonString: String) throws -> [String: Any] {
    guard let jsonData = jsonString.data(using: .utf8),
      let data = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
        throw Server.ServerError.incorrectFormat
    }
    guard let result = data?["result"] as? Int else {
      try handleErrorResult(jsonData: data!)
      throw Server.ServerError.incorrectFormat
    }
    
    if result != 0 {
      let message = (data?["message"] as? String) ?? "Ошибка в данных"
      print("message = \(String(describing: response))")
      throw ServerError.httpError(code: result, message: message)
    }
    
    guard let dataResponse = data?["response"] as? [String: Any] else {
        throw Server.ServerError.incorrectFormat
    }
    
    return dataResponse
  }
  
  func handleErrorResult(jsonData: [String: Any]) throws {
    guard let dataResponse = jsonData["response"] as? [String: Any] else {
      throw Server.ServerError.incorrectFormat
    }
    guard let result = dataResponse["result"] as? Int else {
      throw Server.ServerError.incorrectFormat
    }
    guard let base64Encoded = dataResponse["message"] as? String else {
      throw Server.ServerError.incorrectFormat
    }
    let decodedData = Data(base64Encoded: base64Encoded)!
    let decodedString = String(data: decodedData, encoding: .utf8)!
    print("message = \(String(describing: response))")
    throw ServerError.httpError(code: result, message: decodedString)
  }
  
  
  private var data: Data?
  private var error: Error?
  private var response: URLResponse?
}

