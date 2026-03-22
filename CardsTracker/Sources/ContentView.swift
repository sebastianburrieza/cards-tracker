import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "creditcard")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Cards Tracker")
                .font(.largeTitle)
                .bold()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
