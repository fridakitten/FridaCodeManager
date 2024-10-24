/* 
 UICodePreview.swift 

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
import Foundation
import UIKit

struct CodeEditorPreview: View {
    @AppStorage("fontname") var fname: String = "Menlo"
    @AppStorage("bsl") var bsl: Bool = true
    @AppStorage("fbold") var bold: Bool = false
    @AppStorage("defbakcolor") var dbc: Bool = true
    @AppStorage("deftextcolor") var dtc: Bool = true

    @Binding var text: String
    @Binding var font: CGFloat
    @State var rules: [HighlightRule]
    init(text: Binding<String>,font: Binding<CGFloat>, suffix: String) {
        _text = text
        _font = font
        _rules = State(initialValue: grule(suffix))
    }
    var body: some View {
        ZStack {
            if dbc {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
            } else {
                loadColor("C7")
                    .ignoresSafeArea()
            }
/*            HighlightedTextEditor(text: $text, highlightRules: rules)
                .introspect { editor in
                     editor.textView.font = UIFont(name: "\(fname)\(bold ? "-Bold" : "")", size: font)
                     editor.textView.backgroundColor = .clear
                     editor.textView.tintColor = UIColor(Color.primary)
                     editor.textView.keyboardType = .asciiCapable
                     editor.textView.autocorrectionType = .no
                     editor.textView.autocapitalizationType = .none
                     editor.textView.textContentType = .none
                     editor.textView.smartQuotesType = .no
                     editor.textView.smartDashesType = .no
                     editor.textView.smartInsertDeleteType = .no
                     editor.textView.layoutManager.allowsNonContiguousLayout = false
                     editor.textView.isEditable = false
                     editor.textView.isUserInteractionEnabled = false
                     if bsl {
                         editor.textView.layer.shadowColor = UIColor.black.cgColor
                         editor.textView.layer.shadowRadius = 1
                         editor.textView.layer.shadowOpacity = 0.2
                         editor.textView.layer.shadowOffset = CGSize(width: 0, height: 1)
                     }
                }*/
        }
    }
}
