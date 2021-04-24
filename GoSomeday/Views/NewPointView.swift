//
//  NewPointView.swift
//  GoSomeday
//
//  Created by yum on 2021/04/13.
//

import SwiftUI

struct NewPointView: View {
    @State var title = ""
    @State var subtitle = ""
    
    var body: some View {
        VStack {
            TextField("タイトル", text: self.$title)
                .padding()
            
            TextField("サブタイトル", text: self.$subtitle)
                .padding()
                .disabled(true)
                .foregroundColor(.secondary)
        }
    }
}

struct NewPointView_Previews: PreviewProvider {
    static var previews: some View {
        NewPointView(title: "タイトル", subtitle: "サブタイトル")
    }
}
