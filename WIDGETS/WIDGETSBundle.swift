//
//  WIDGETSBundle.swift
//  WIDGETS
//
//  Created by Joao Leite on 7/6/25.
//

import WidgetKit
import SwiftUI

@main
struct WIDGETSBundle: WidgetBundle {
    var body: some Widget {
        SweeplyWidget()
        WIDGETSControl()
        WIDGETSLiveActivity()
    }
}
