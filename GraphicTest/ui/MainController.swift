//
//  MainController.swift
//  GhaphicTest
//
//  Created by Виталий Антипов on 23.06.2018.
//  Copyright © 2018 Виталий Антипов. All rights reserved.
//

import UIKit

class MainController: UIViewController {

  @IBOutlet var graphView: GraphView!
  var service: GraphicService!
  struct Constant{
    static let dx: CGFloat = 1.0
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    
    service = GraphicService()
  }
  
  @IBAction func loadData(_ sender: Any) {
    load()
  }
  
  func load() {
    do {
      let graphic = try service.load(maxCount: 5)
      drawGraph(graphic)
    } catch {
      let alert = ErrorHandler.alert(error)
      present(alert, animated: true)
    }
  }
  
  func drawGraph(_ graphic: Graphic) {
    let inputPoints = graphic.points
    graphView.series.append((inputPoints, UIColor.red))
    
    let akima = AkimaInterpolator(points: inputPoints)
    
    var splinePoints = [CGPoint]()
    var x = inputPoints.first!.x
    while x<=inputPoints.last!.x {
      
      splinePoints.append(CGPoint(x: x, y: akima.interpolate(value: x)))
      x += Constant.dx
    }
    
    graphView.series.append((splinePoints, UIColor.blue))
    graphView.setNeedsDisplay()
  }

}