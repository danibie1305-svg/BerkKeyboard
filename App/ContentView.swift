import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView().tabItem { Label("Home", systemImage: "keyboard") }
            GuideView().tabItem { Label("Guida", systemImage: "list.number") }
            RuneTableView().tabItem { Label("Rune", systemImage: "textformat") }
            SettingsView().tabItem { Label("Impostazioni", systemImage: "gearshape") }
        }
    }
}

struct HomeView: View {
    @State private var text = ""
    private let rows = ["QWERTYUIOP", "ASDFGHJKL", "ZXCVBNM"]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Berk Keyboard").font(.largeTitle.bold())
                Text("Una tastiera QWERTY con rune vichinghe. Mostra le rune, scrive lettere normali.")
                    .multilineTextAlignment(.center).foregroundColor(.secondary)
                VStack(spacing: 6) {
                    ForEach(rows, id: \.self) { row in
                        HStack(spacing: 5) {
                            ForEach(Array(row), id: \.self) { ch in
                                Text(RuneMap.rune(for: String(ch)))
                                    .font(.system(size: 18))
                                    .frame(maxWidth: .infinity, minHeight: 40)
                                    .background(Color(red: 0.23, green: 0.24, blue: 0.25))
                                    .foregroundColor(Color(red: 0.95, green: 0.91, blue: 0.82))
                                    .cornerRadius(5)
                            }
                        }
                    }
                }
                .padding(8).background(Color(red: 0.11, green: 0.11, blue: 0.12)).cornerRadius(10)
                Text("Prova qui sotto (dopo averla attivata):").font(.footnote).foregroundColor(.secondary)
                TextField("Scrivi qualcosa…", text: $text).textFieldStyle(.roundedBorder)
            }
            .padding()
        }
    }
}

struct GuideView: View {
    var body: some View {
        List {
            Text("1. Apri Impostazioni › Generali › Tastiera › Tastiere.")
            Text("2. Tocca «Aggiungi nuova tastiera…» e scegli Berk Keyboard.")
            Text("3. In qualsiasi app tieni premuto il globo 🌐 e scegli Berk Keyboard.")
            Text("Non serve «Consenti accesso completo»: la tastiera non raccoglie né trasmette nulla.")
        }
    }
}

struct RuneTableView: View {
    var body: some View {
        List(RuneMap.table, id: \.letter) { item in
            HStack {
                Text(item.letter).font(.headline).frame(width: 40, alignment: .leading)
                Spacer()
                Text(item.rune).font(.title2)
            }
        }
    }
}

struct SettingsView: View {
    @AppStorage("theme") private var theme = "system"
    var body: some View {
        Form {
            Picker("Tema app", selection: $theme) {
                Text("Sistema").tag("system")
                Text("Chiaro").tag("light")
                Text("Scuro").tag("dark")
            }
            .pickerStyle(.segmented)
        }
    }
}
