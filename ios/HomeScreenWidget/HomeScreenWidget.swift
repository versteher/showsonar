import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), title: "Tonight's Pick", description: "Loading...")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), title: "Tonight's Pick", description: "Movie information will appear here")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // User defaults group should be created manually in Xcode
        let userDefaults = UserDefaults(suiteName: "group.com.neonvoyager.neonvoyager.widget")
        let title = userDefaults?.string(forKey: "title") ?? "Tonight's Pick"
        let description = userDefaults?.string(forKey: "description") ?? "No recommendations."

        let entry = SimpleEntry(date: Date(), title: title, description: description)
        entries.append(entry)

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let title: String
    let description: String
}

struct HomeScreenWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.title)
                .font(.headline)
            Text(entry.description)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

@main
struct HomeScreenWidget: Widget {
    let kind: String = "HomeScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            HomeScreenWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Tonight's Pick")
        .description("Shows movie recommendations for you.")
    }
}
