//
//  HomeView.swift
//  WankoNetwork
//
//  Created by satoshoco on 2023/09/08.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Profile.entity(), sortDescriptors: []) var profiles: FetchedResults<Profile>
    @FetchRequest(entity: Dog.entity(), sortDescriptors: []) var dogs: FetchedResults<Dog>
    @State private var searchText = ""
    
    
    // mmenu
    @State private var offset = CGFloat.zero
    @State private var closeOffset = CGFloat.zero
    @State private var openOffset = CGFloat.zero
    
    
    init(){
        let navigationBarAppearance = UINavigationBarAppearance()
        let mainUIColor = UIColor(named: "mainColor") ?? UIColor.green
        UINavigationBar.appearance().tintColor = .white
        navigationBarAppearance.backgroundColor = UIColor.orange
        
    }
    
    var body: some View {
            ZStack(alignment: .top){
                // Main Content
                NavigationView {
                    ZStack {
                        // dog list
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
                                        Image(uiImage: UIImage(data: dog.photo ?? Data()) ?? UIImage(named: "wanko2")!)
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
                       
                        if self.offset != self.closeOffset {
                            Color.gray.opacity(
                                Double((self.closeOffset - self.offset)/self.closeOffset) - 0.4
                            )
                            .onTapGesture {
                                withAnimation {
                                    self.offset = self.closeOffset
                                }
                            }
                        }
                    }
                    .background(Color("mainColor"))
                    // gray background
                    
                    // navi
                    .navigationBarItems(trailing: NavigationLink(destination: DogFormView()) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                    })
                }
                .tint(.white)

                //logo
                TitleView(image: Image("wanko"),titleName: "wanko")

                
            }
        
    }
}

struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
                textField.backgroundColor = .white
            }

            searchBar.placeholder = "Search"
            searchBar.barTintColor = .white
            searchBar.searchBarStyle = .minimal
            searchBar.backgroundImage = UIImage()
            searchBar.scopeBarBackgroundImage = UIImage()

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
