//
//  ComplicationViews.swift
//  LinkedCounter WatchKit Extension
//
//  Created by yoonbumtae on 2022/09/25.
//

import SwiftUI
import ClockKit

struct ComplicationViewCircular: View {
    @State var current: Double
    @State var target: Double
    
    
    var body: some View {
        ZStack {
            ProgressView(current.intText, value: current, total: target)
                .progressViewStyle(CircularProgressViewStyle(tint: .red))
        }
    }
}

struct ComplicationViews_Previews: PreviewProvider {
    static var previews: some View {
        // 1
        Group {
            // 2
            CLKComplicationTemplateGraphicCircularView(
                ComplicationViewCircular(current: 800, target: 3000)
                // 3
            ).previewContext()
        }
    }
}
