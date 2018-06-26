//
//  MainController.swift
//  GhaphicTest
//
//  Created by Виталий Антипов on 23.06.2018.
//  Copyright © 2018 Виталий Антипов. All rights reserved.
//

import UIKit

class MainController: UIViewController, UITextFieldDelegate {
	
	@IBOutlet private var textField: UITextField!
	
	@IBOutlet private var graphView: GraphView!
	private var service: GraphicService!
	
	@IBOutlet private var saveGraphicBtn: UIButton!
	
	private var graphic: Graphic!
	struct Constant {
		static let dx: CGFloat = 1.0
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		
		saveGraphicBtn.isEnabled = false
		service = GraphicService()
	}
	
	@IBAction func loadData(_: Any) {
		textField.resignFirstResponder()
		guard let text = textField.text, let numPoints = Int(text) else {
			let alert = ErrorHandler.alert(Errors.custom(message: "Введите число"))
			present(alert, animated: true)
			return
		}
		load(numPoints: numPoints)
	}
	
	private func load(numPoints: Int) {
		DispatchQueue.global(qos: .default).async { [weak self] in
			guard let strong = self else {
				return
			}
			do {
				strong.graphic = try strong.service.load(maxCount: numPoints)
				DispatchQueue.main.async {
					strong.saveGraphicBtn.isEnabled = true
					strong.drawGraph(strong.graphic)
				}
			} catch {
				DispatchQueue.main.async {
					let alert = ErrorHandler.alert(error)
					strong.present(alert, animated: true)
				}
			}
		}
	}
	
	private func drawGraph(_ graphic: Graphic) {
		graphView.series.removeAll()
		let inputPoints = graphic.points
		graphView.series.append((inputPoints, UIColor.red))
		
		let akima = AkimaInterpolator(points: inputPoints)
		
		var splinePoints = [CGPoint]()
		var x = inputPoints.first!.x
		while x <= inputPoints.last!.x {
			
			splinePoints.append(CGPoint(x: x, y: akima.interpolate(value: x)))
			x += Constant.dx
		}
		graphView.series.append((splinePoints, UIColor.green))
		graphView.setNeedsDisplay()
	}
	
	@IBAction func saveGraphic(_: Any) {
		DispatchQueue.global(qos: .default).async { [weak self] in
			guard let strong = self else {
				return
			}
			do {
				try strong.service.save(graphic: strong.graphic)
			} catch {
				DispatchQueue.main.async {
					let alert = ErrorHandler.alert(error)
					strong.present(alert, animated: true)
				}
			}
		}
	}
	
}
