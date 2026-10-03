import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true
    @AppStorage("soundsEnabled") private var soundsEnabled = true

    var body: some View {
        NavigationStack {
            Form {
                Section("feedback") {
                    Toggle(isOn: $hapticsEnabled) {
                        Label { Text("haptics") } icon: { HandyFeedbackSymbol(kind: .haptics, enabled: hapticsEnabled) }
                    }
                    Toggle(isOn: $soundsEnabled) {
                        Label { Text("sounds") } icon: { HandyFeedbackSymbol(kind: .sounds, enabled: soundsEnabled) }
                    }
                    Text("a chime when you finish. a soft click when you delete. sounds respect silent mode.")
                        .font(.handWritten(15))
                        .foregroundStyle(.secondary)
                }
                Section("home screen widgets") {
                    Text("touch and hold your home screen, choose edit, then add widget. search for handy and choose the small or large widget.")
                    Text("widgets show unfinished tasks, with primary tasks first. tap a widget to open handy.")
                        .font(.handWritten(15))
                        .foregroundStyle(.secondary)
                }
                Section("made with open source") {
                    Link(destination: URL(string: "https://github.com/Stringsaeed/Handy-Todo")!) {
                        Label { Text("handy on github") } icon: { HandySymbol(.github) }
                    }
                    NavigationLink("oregano · astigmatic") {
                        FontLicenseView(title: "Oregano", credit: "Designed by Brian J. Bonislawsky, Astigmatic. © 2012. Used for Handy's app text under the SIL Open Font License 1.1.",
                                        resource: "Oregano-License", ext: "txt")
                    }
                    Text("font licenses apply to their respective fonts. original handy feedback sounds are included in the source code.")
                        .font(.handWritten(15))
                        .foregroundStyle(.secondary)
                }
            }
            .font(.handWritten(18))
            .scrollContentBackground(.hidden)
            .background(HandyTheme.paper.ignoresSafeArea())
            .foregroundStyle(HandyTheme.ink)
            .toolbarBackground(HandyTheme.paper, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .handyNavigationTitle("settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button { dismiss() } label: {
                        HandySymbol(.close, size: 20).frame(width: 44, height: 44)
                    }
                    .accessibilityLabel("close settings")
                }
            }
        }
        .background(HandyTheme.paper.ignoresSafeArea())
    }
}

private struct FontLicenseView: View {
    let title: String
    let credit: String
    let resource: String
    let ext: String

    private var license: String {
        guard let url = Bundle.main.url(forResource: resource, withExtension: ext),
              let text = try? String(contentsOf: url, encoding: .utf8) else {
            return "License unavailable. See the font license files in Handy's source repository."
        }
        return text
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(credit.lowercased()).font(.handWritten(22))
                Text(license.lowercased()).font(.handWritten(17)).textSelection(.enabled)
            }
            .frame(maxWidth: 680, alignment: .leading)
            .padding(24)
        }
        .background(HandyTheme.paper.ignoresSafeArea())
        .foregroundStyle(HandyTheme.ink)
        .handyNavigationTitle(title.lowercased())
    }
}
