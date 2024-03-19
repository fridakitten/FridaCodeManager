 /* 
 BlobLayer.swift 

 Copyright (C) 2023, 2024 SparkleChan and SeanIsTethered 
 Copyright (C) 2024 fridakitten 

 This file is part of FridaCodeManager. 

 FridaCodeManager is free software: you can redistribute it and/or modify 
 it under the terms of the GNU General Public License as published by 
 the Free Software Foundation, either version 3 of the License, or 
 (at your option) any later version. 

 FridaCodeManager is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of 
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
 GNU General Public License for more details. 

 You should have received a copy of the GNU General Public License 
 along with FridaCodeManager. If not, see <https://www.gnu.org/licenses/>. 
 */ 
    
//
//  BlobLayer.swift
//  BlobLayer
//
//  Created by João Gabriel Pozzobon dos Santos on 04/10/22.
//

import SwiftUI

/// A CALayer that draws a single blob on the screen
public class BlobLayer: CAGradientLayer {
    init(color: Color) {
        super.init()
        
        self.type = .radial
        #if os(OSX)
        autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        #endif
        
        // Set color
        set(color: color)
        
        // Center point
        let position = newPosition()
        self.startPoint = position
        
        // Radius
        let radius = newRadius()
        self.endPoint = position.displace(by: radius)
    }
    
    /// Generate a random point on the canvas
    func newPosition() -> CGPoint {
        return CGPoint(x: CGFloat.random(in: 0.0...1.0),
                       y: CGFloat.random(in: 0.0...1.0)).capped()
    }
    
    /// Generate a random radius for the blob
    func newRadius() -> CGPoint {
        let size = CGFloat.random(in: 0.15...0.75)
        let viewRatio = frame.width/frame.height
        let safeRatio = max(viewRatio.isNaN ? 1 : viewRatio, 1)
        let ratio = safeRatio*CGFloat.random(in: 0.25...1.75)
        return CGPoint(x: size,
                       y: size*ratio)
    }
    
    /// Animate the blob to a random point and size on screen at set speed
    func animate(speed: CGFloat) {
        guard speed > 0 else { return }
        
        self.removeAllAnimations()
        let currentLayer = self.presentation() ?? self
        
        let animation = CASpringAnimation()
        animation.mass = 10/speed
        animation.damping = 50
        animation.duration = 1/speed
        
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        
        let position = newPosition()
        let radius = newRadius()
        
        // Center point
        let start = animation.copy() as! CASpringAnimation
        start.keyPath = "startPoint"
        start.fromValue = currentLayer.startPoint
        start.toValue = position
        
        // Radius
        let end = animation.copy() as! CASpringAnimation
        end.keyPath = "endPoint"
        end.fromValue = currentLayer.endPoint
        end.toValue = position.displace(by: radius)
        
        self.startPoint = position
        self.endPoint = position.displace(by: radius)
        
        // Opacity
        let value = Float.random(in: 0.5...1)
        let opacity = animation.copy() as! CASpringAnimation
        opacity.fromValue = self.opacity
        opacity.toValue = value
        
        self.opacity = value
        
        self.add(opacity, forKey: "opacity")
        self.add(start, forKey: "startPoint")
        self.add(end, forKey: "endPoint")
    }
    
    /// Set the color of the blob
    func set(color: Color) {
        // Converted to the system color so that cgColor isn't nil
        self.colors = [SystemColor(color).cgColor,
                       SystemColor(color).cgColor,
                       SystemColor(color.opacity(0.0)).cgColor]
        self.locations = [0.0, 0.9, 1.0]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Required by the framework
    public override init(layer: Any) {
        super.init(layer: layer)
    }
}
