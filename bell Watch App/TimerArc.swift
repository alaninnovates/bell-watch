//
//  TimerArc.swift
//  bell Watch App
//
//  Created by Alan Chen on 1/22/24.
//

import Foundation
import SwiftUI

struct TimerArc: Shape {
  let currentSeconds: Int
  let totalSeconds: Int

  func path(in rect: CGRect) -> Path {
    var path = Path()
    let center = CGPoint(x: rect.midX, y: rect.midY)
    let radius = min(rect.width, rect.height) / 2
    let startAngle = Angle(degrees: 270)
    let endAngle = Angle(degrees: 270 - (Double(currentSeconds) / Double(totalSeconds)) * 360)
    path.addArc(
      center: center, radius: radius, startAngle: endAngle, endAngle: startAngle, clockwise: false)
    path.addLine(to: center)
    path.closeSubpath()
    return path
  }
}

struct PartialRoundedRectangle: Shape {
  let cornerRadius: CGFloat

  let currentSeconds: Int
  let totalSeconds: Int

  func path(in rect: CGRect) -> Path {
    var path = Path()
    // make a rounded rectangle that draws a line that is currentSeconds / totalSeconds of the way around the rectangle
    path.move(to: CGPoint(x: cornerRadius, y: rect.height))
    path.addArc(
      tangent1End: CGPoint(x: 0, y: rect.height),
      tangent2End: CGPoint(x: 0, y: rect.height - cornerRadius), radius: cornerRadius)
    path.addLine(to: CGPoint(x: 0, y: cornerRadius))
    path.addArc(
      tangent1End: CGPoint(x: 0, y: 0), tangent2End: CGPoint(x: cornerRadius, y: 0),
      radius: cornerRadius)
    path.addLine(to: CGPoint(x: rect.width - cornerRadius, y: 0))
    path.addArc(
      tangent1End: CGPoint(x: rect.width, y: 0),
      tangent2End: CGPoint(x: rect.width, y: cornerRadius), radius: cornerRadius)
    path.addLine(to: CGPoint(x: rect.width, y: rect.height - cornerRadius))
    path.addArc(
      tangent1End: CGPoint(x: rect.width, y: rect.height),
      tangent2End: CGPoint(x: rect.width - cornerRadius, y: rect.height), radius: cornerRadius)
    path.addLine(to: CGPoint(x: cornerRadius, y: rect.height))
    return path.strokedPath(.init(lineWidth: 2))
  }
}
