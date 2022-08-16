import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store: Store<AppState, AppAction>
    @State private var path = NavigationPath()
    @State private var day: Int  = 1
    var body: some View {
        NavigationSplitView {
            List(selection: $day){
                NavigationLink(value: 1) {
                    Label("Day1", systemImage: "box.truck")
                }
                NavigationLink(value: 2) {
                    Label("Day2", systemImage: "box.truck")
                }
                NavigationLink(value: 3) {
                    Label("Day3", systemImage: "box.truck")
                }
            }
        } detail: {
            NavigationStack(path: $path){
                TimetableView(day: $day)
            }
        }
        .onChange(of: day) { _ in
            path.removeLast(path.count)
        }

    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: Store(initialState: AppState(), reducer: appReducer, environment: AppEnvironment()))
    }
}
