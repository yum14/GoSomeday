//
//  HomeView.swift
//  GoSomeday
//
//  Created by yum on 2021/04/12.
//

import SwiftUI
import MapKit
import PartialSheet

struct HomeView: View {
    @ObservedObject var viewModel = HomeViewModel()
    @EnvironmentObject var partialSheetManager: PartialSheetManager
    
    @State var alert = false
    @ObservedObject private var searchHistoryStore = SearchHistoryStore.shared
    
    
    var body: some View {
        NavigationView {
            ZStack {
                ZStack {
                    ZStack {
                        MapView(coordinateRegion: self.$viewModel.region,
                                manager: self.$viewModel.manager,
                                alert: $alert,
                                moveCurrentLocation: self.$viewModel.moveCurrentLocation,
                                moveCoordinateRegion: self.$viewModel.moveCoordinateRegion,
                                annotations: self.viewModel.annotations,
                                onTapGesture: { coordinate, placemark in
                                    let annotation: PointAnnotation = self.viewModel.onMapViewTap(coordinate: coordinate, placemark: placemark)
                                    
                                    self.partialSheetManager.showPartialSheet({
                                        self.viewModel.onNewPointViewDismiss(id: annotation.id)
                                    }) {
                                        NewPointView(title: annotation.title ?? "", subtitle: annotation.subtitle ?? "")
                                    }
                                    
                                }
                        )
                        .alert(isPresented: $alert) {
                            Alert(title: Text("Please Enable Location Access In Setting Panel!!!"))
                        }
                        
                        // SearchBarタップ時にMapViewを隠すためのView
                        if self.viewModel.searching {
                            VStack {}
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color(UIColor.systemBackground))
                        }
                    }
                    .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 0) {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: self.viewModel.onLocationButtonTap, label: {
                                Image(systemName: "location.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .padding()
                            })
                            .background(Color.blue)
                            .cornerRadius(.greatestFiniteMagnitude)
                            .shadow(color: Color.black.opacity(0.3),
                                    radius: 5,
                                    x: 3,
                                    y: 3)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                    }
                }
                
                
                VStack(spacing: 0) {
                    SearchBar(text: self.$viewModel.searchText,
                              placeholder: "Search ...",
                              onCommit: { text in
                                // 決定は最初の1件目を選択したこととする
                                if let item = self.viewModel.mapItems.first {
                                    self.viewModel.onSearchBarCommit(item: item)
                                }
                              },
                              onCancel: {
                                self.viewModel.searching = false
                              },
                              onBeginEditing: {
                                withAnimation {
                                    self.viewModel.searching = true
                                }
                              },
                              resignFirstResponder: self.$viewModel.resignFirstResponder
                    )
                    .padding(.vertical, -10)
                    
                    if self.viewModel.searching {
                        if self.viewModel.searchText.isEmpty {
                            withAnimation {
                                SearchHistoryList(
                                    items: self.searchHistoryStore.mapItems.sorted(by: { $0.order > $1.order }),
                                    onTap: self.viewModel.onSearchHistoryListTap)
                                    .listStyle(PlainListStyle())
                            }
                        } else {
                            withAnimation {
                                SearchResultList(items: self.viewModel.mapItems,
                                                 onTap: self.viewModel.onSearchResultTap)
                                    .listStyle(PlainListStyle())
                            }
                        }
                    } else {
                        withAnimation {
                            Spacer()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .addPartialSheet()
        
    }
}

struct HomeView_Previews: PreviewProvider {
    
    static var previews: some View {
        HomeView()
            .environmentObject(PartialSheetManager())
    }
}
