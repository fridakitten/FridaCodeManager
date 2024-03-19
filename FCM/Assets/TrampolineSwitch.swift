// By. SeanIsTethered
// 29.02.2024
import SwiftUI

extension Binding where Value: Equatable {
    func trampolineIfNeeded(to: Value, via: Value) {
        if wrappedValue == to {
            wrappedValue = via
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
                wrappedValue = to
            })
        } else {
            wrappedValue = to
        }
    }
}

extension Binding where Value == Bool {
    func trampolineIfNeeded(to: Value) {
        trampolineIfNeeded(to: to, via: !to)
    }
}