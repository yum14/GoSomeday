//
//  ContentView.swift
//  GoSomeday
//
//  Created by yum on 2021/04/12.
//

import SwiftUI
import PartialSheet

struct ContentView: View {
    let sheetManager = PartialSheetManager()
    var localSearchModel = LocalSearchModel()
    
    var body: some View {
        HomeView()
            .environmentObject(sheetManager)
            .environmentObject(localSearchModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
