//
//  File.swift
//  GhaphicTest
//
//  Created by Виталий Антипов on 23.06.2018.
//  Copyright © 2018 Виталий Антипов. All rights reserved.
//

import UIKit

enum Errors: Error {
	case invalidURL
	case httpError(code: Int, message: String)
	case custom(message: String)
	case incorrectFormat
	case saveError
}

class ErrorHandler {
  
  class func alert(_ error: Error) -> UIAlertController {
    var message: String
    switch error {
    case Errors.invalidURL:
      message = "Задан неверный формат URL строки"
    case let Errors.httpError(code: code, message: errMess):
      message = "Ошибка сервера \(code): \(errMess)"
    case let Errors.custom(message: errMess):
      message = errMess
		case Errors.saveError:
			message = "Ошибка записи в файл"
    case Errors.incorrectFormat:
      message = "Получен неверный формат данных с сервера"
    case let nserror as NSError:
      message = nserror.localizedDescription
    default:
      message = "Произошла ошибка попробуйте повторить позднее"
    }
    
    return createAlert(message: message)
  }
  
  private class func createAlert(message: String) -> UIAlertController {
    let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel))
    return alert
  }
}
