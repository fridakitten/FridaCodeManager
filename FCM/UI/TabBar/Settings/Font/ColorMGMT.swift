/* 
 ColorMGMT.swift 

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
 
import SwiftUI

func saveColor(_ key: String, _ color: Color) {
    var result: String = ""
    result = colorToRGBString(color)

    UserDefaults.standard.set(result, forKey: key)
}
func loadColor(_ key: String) -> Color {
    var color: Color = Color.black

    if let colorStr = UserDefaults.standard.value(forKey: key) as? String {
        color = RGBStringToColor(colorStr)
    }

    return color
}

func colorToRGBString(_ color: Color) -> String {
    let uiColor = UIColor(color)
    var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
    let redInt = Int(red * 255)
    let greenInt = Int(green * 255)
    let blueInt = Int(blue * 255)
    
    return "\(redInt),\(greenInt),\(blueInt)"
}
func RGBStringToColor(_ rgbString: String) -> Color {
    let components = rgbString.components(separatedBy: ",").compactMap { Int($0) }
    guard components.count == 3 else {
        return .black
    }
    
    let red = Double(components[0]) / 255.0
    let green = Double(components[1]) / 255.0
    let blue = Double(components[2]) / 255.0
    
    return Color(red: red, green: green, blue: blue)
}