//
//  ComplicationController.swift
//  LinkedCounter WatchKit Extension
//
//  Created by yoonbumtae on 2022/09/23.
//

import ClockKit
import SwiftUI

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Complication Configuration

    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(identifier: "complication", displayName: "LinkedCounter", supportedFamilies: CLKComplicationFamily.allCases)
            // Multiple complication support can be added here with more descriptors
        ]
        
        // Call the handler with the currently supported complication descriptors
        handler(descriptors)
    }
    
    func handleSharedComplicationDescriptors(_ complicationDescriptors: [CLKComplicationDescriptor]) {
        // Do any necessary work to support these newly shared complication descriptors
    }

    // MARK: - Timeline Configuration
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        // Call the handler with the last entry date you can currently provide or nil if you can't support future timelines
        let after = Date().timeIntervalSince1970 + (60 * 60) * 60
        handler(Date(timeIntervalSince1970: after))
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        // Call the handler with your desired behavior when the device is locked
        handler(.showOnLockScreen)
    }

    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        
        if let template = makeTemplate(image: UIImage(systemName: "star.fill")!, complication: complication) {
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
        } else {
            handler(nil)
        }
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after the given date

        var dataRead = false
        // CurrentData.shared.targetCount = 3000.0

        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [self] timer in
            
            if dataRead {
                timer.invalidate()
                return
            }
            
            var entries: [CLKComplicationTimelineEntry] = []
            
            if let totalCount = CurrentData.shared.currentTotalCount,
               let targetCount = CurrentData.shared.targetCount,
               let template = makeTemplate(current: totalCount, target: targetCount, complication: complication) {
                let entry = CLKComplicationTimelineEntry(
                    date: Date(),
                    complicationTemplate: template)
                entries.append(entry)
                
                dataRead = true
                timer.invalidate()
                handler(entries)
            }
        }
    }

    // MARK: - Sample Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        handler(nil)
    }
}


extension ComplicationController {
    
    func makeTemplate(text: String, complication: CLKComplication) -> CLKComplicationTemplate? {
        if complication.family == .circularSmall {
            return CLKComplicationTemplateCircularSmallRingText(textProvider: CLKTextProvider(format: text), fillFraction: 0.0, ringStyle: .closed)
        }
        
        return nil
    }
    
    func makeTemplate(image: UIImage, complication: CLKComplication) -> CLKComplicationTemplate? {
        
        switch complication.family {
        case .circularSmall:
            return CLKComplicationTemplateCircularSmallRingImage(imageProvider: CLKImageProvider(onePieceImage: image), fillFraction: 0.0, ringStyle: .closed)
        default:
            return nil
        }
    }
    
    func makeTemplate(current: Double, target: Double, complication: CLKComplication) -> CLKComplicationTemplate? {
        let percentage = current / target
        
        switch complication.family {
        case .graphicCircular:
            return CLKComplicationTemplateGraphicCircularView(ComplicationViewCircular(current: current, target: target))
        case .circularSmall:
            return CLKComplicationTemplateCircularSmallRingText(textProvider: CLKTextProvider(format: current.rationalizedText), fillFraction: Float(percentage), ringStyle: .closed)
        default:
            return nil
        }
    }
}
