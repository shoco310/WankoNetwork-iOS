//
//  HomeView.swift
//  WankoNetwork
//
//  Created by satoshoco on 2023/09/08.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Dog.entity(), sortDescriptors: []) var dogs: FetchedResults<Dog>
    @State private var searchText = ""
    @State private var isMenuOpen = false
    
    init(){
        let mainUIColor = UIColor(named: "mainColor") ?? UIColor.green
        UINavigationBar.appearance().barTintColor = mainUIColor
        UINavigationBar.appearance().backgroundColor = mainUIColor
        UISearchBar.appearance().backgroundColor = mainUIColor
        UISearchBar.appearance().barTintColor = mainUIColor
        UITableView.appearance().backgroundColor = mainUIColor
        UITableViewCell.appearance().backgroundColor = UIColor.white
        UISearchBar.appearance().searchTextField.backgroundColor = UIColor.white
        UITableView.appearance().separatorStyle = .none
    }
     
    var body: some View {
        ZStack(alignment: .top){
            
            NavigationView {
                VStack {
                    SearchBar(text: $searchText)
                    List(dogs.filter { dog in
                        searchText.isEmpty || dog.name?.localizedStandardContains(searchText) == true
                    }, id: \.self) { dog in
                        NavigationLink(destination: DetailView(dog: dog)) {
                            EmptyView()
                        }
                        .frame(height: 40)
                        .background(
                            HStack {
                                Image(uiImage: UIImage(data: dog.photo ?? Data()) ?? UIImage())
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 35, height: 35)
                                    .clipShape(Circle())
                                Text(dog.name ?? "")
                                Spacer()
                                
                                Button(action: {
                                    // Detail action
                                }) {
                                    Text("Detail")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 15)
                                        .padding(.vertical, 10)
                                }
                                .background(Color.clear)
                                
                            }
                        )
                        
                    }
                }
                .background(Color("mainColor"))
                .navigationBarItems(leading:
                                        Button(action: {
                    withAnimation {
                        isMenuOpen.toggle()
                    }
                }, label: {
                    Image(systemName: "line.horizontal.3")
                        .foregroundColor(.white)
                }), trailing:NavigationLink(destination: DogFormView()) {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                }
                )
            }
            TitleView(image: Image("wanko"),titleName: "wanko")
        }
        
    }
}

struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        
        // SearchBarの入力項目以外の背景を緑にする
        searchBar.barTintColor = .white
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundImage = UIImage()
        searchBar.text = "Search"
        
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
    
    func makeCoordinator() -> SearchBarCoordinator {
        return SearchBarCoordinator(text: $text)
    }
    
    class SearchBarCoordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        
        init(text: Binding<String>) {
            _text = text
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
    }
}
