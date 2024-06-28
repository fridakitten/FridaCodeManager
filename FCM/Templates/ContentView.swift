//
//
//  ContentView.swift
//  Created by %(author) at %(time)
//  This is a part of the %(project)
//
//

import Foundation
import SwiftUI

struct ContentView: View {
	var body: some View {
		Text(hello())
	}

	func hello() -> String {
		let instance = MyObjectiveCClass()
		return instance.hello()
	}
}
