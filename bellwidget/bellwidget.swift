//
//  bellwidget.swift
//  bellwidget
//
//  Created by Alan Chen on 1/23/24.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }
    
    func snapshot(in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date())
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
//    let configuration: ConfigurationAppIntent
}

struct ComplicationCircular: View {
    var body: some View {
        Image(systemName: "multiply.circle.fill")
            .widgetAccentable(true)
            .unredacted()
    }
}
struct ComplicationCorner: View {
    var body: some View {
        Gauge(value: 10, in: 0...28) {
        } currentValueLabel: {
            Text("00.30.00")
        }
        .gaugeStyle(.accessoryCircularCapacity)
    }
}

struct bellwidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry
    
    var body: some View {
        
        switch widgetFamily {
        case .accessoryCorner:
            ComplicationCorner()
        case .accessoryCircular:
            ComplicationCircular()
        case .accessoryRectangular:
            Text("TrapScores")
        case .accessoryInline:
            Text("TrapScores")
        @unknown default:
            Text("AppIcon")
        }
    }
}

@main
struct bellwidget: Widget {
    let kind: String = "bellwidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            bellwidgetEntryView(entry: entry)
                .containerBackground(.fill.secondary, for: .widget)
        }
        .configurationDisplayName("Bell")
        .description("This will launch the Bell App")
        .supportedFamilies([.accessoryCorner, .accessoryCircular])
    }

}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        return intent
    }
}

#Preview(as: .accessoryCorner) {
    bellwidget()
} timeline: {
    SimpleEntry(date: .now)
}    
