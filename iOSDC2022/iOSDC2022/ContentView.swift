//
//  ContentView.swift
//  iOSDC2022
//
//  Created by 朱冰一 on 2022/08/13.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store: Store<AppState, AppAction>
    var body: some View {
        NavigationView {
            WithViewStore(self.store) { viewStore in
                Text("Hello")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: Store(initialState: AppState(), reducer: appReducer, environment: AppEnvironment()))
    }
}
