//
//  iOSDC2022App.swift
//  iOSDC2022
//
//  Created by 朱冰一 on 2022/08/13.
//

import SwiftUI
import ComposableArchitecture

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { start, action, environemnt in
    switch action {}
}

@main
struct iOSDC2022App: App {
    var body: some Scene {
        WindowGroup {
            ContentView(store: Store(initialState: AppState(), reducer: appReducer, environment: AppEnvironment()))
        }
    }
}
