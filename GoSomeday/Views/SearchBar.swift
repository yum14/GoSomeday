//
//  SearchBar.swift
//  GoSomeday
//
//  Created by yum on 2021/04/13.
//

import Foundation
import SwiftUI
import MapKit

struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    
    var placeholder: String?
    var onCommit: (String) -> Void = { _ in }
    var onCancel: () -> Void = {}
    var onBeginEditing: () -> Void = {}
//    var onTextChanged: (String?) -> Void = { _ in }
    
    @Binding var resignFirstResponder: Bool
    
    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = placeholder
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none
        searchBar.showsCancelButton = false
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
        
        if self.resignFirstResponder {
            uiView.resignFirstResponder()
            self.resignFirstResponder.toggle()
        }
        
    }
    
    func makeCoordinator() -> SearchBar.Coordinator {
        Coordinator(text: $text,
                    onCommit: self.onCommit,
                    onCancel: self.onCancel,
                    onBeginEditing: self.onBeginEditing
//                    ,onTextChanged: self.onTextChanged
        )
    }
    
    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        private var onCommit: (String) -> Void = { _ in }
        private var onCancel: () -> Void = {}
        private var onBeginEditing: () -> Void = {}
//        private var onTextChanged: (String?) -> Void = { _ in }

        init(text: Binding<String>,
             onCommit: @escaping (String) -> Void = { _ in },
             onCancel: @escaping () -> Void = {},
             onBeginEditing: @escaping () -> Void = {}) {
            _text = text
            self.onCommit = onCommit
            self.onCancel = onCancel
            self.onBeginEditing = onBeginEditing
//            self.onTextChanged = onTextChanged
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
            searchBar.showsCancelButton = false
            searchBar.endEditing(true)

            if let text = searchBar.text {
                self.onCommit(text)
            }
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            self.text = searchText
        }
        
        // TODO: 日本語文字確定前のインクリメントサーチを行う場合。
        // Viewがリフレッシュされてしまい入力中の文字が削除されてしまう・・。        
//        func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
//                // 100ms delayをかけて実行
//                self.onTextChanged(searchBar.text)
//
//            }
//            return true
//        }
        
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            text = ""
            searchBar.resignFirstResponder()
            searchBar.showsCancelButton = false
            searchBar.endEditing(true)
            self.onCancel()
        }
        
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            searchBar.showsCancelButton = true
            self.onBeginEditing()
        }
        
     }
}

