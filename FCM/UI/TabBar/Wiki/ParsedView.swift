//
// View.swift
//
// Created by SeanIsNotAConstant on 07.11.24
//
 
import SwiftUI

struct XMLDetailView: View {
    let title: String
    let filePath: String
    @State private var hierarchy: Hierarchy?
    
    var body: some View {
            ScrollView() {
                Spacer().frame(height: 10)
                if let hierarchy = hierarchy {
                    ForEach(hierarchy.sections) { section in
                        VStack(alignment: .leading, spacing: 5) {
                            HStack() {
                                Spacer().frame(width: 10)
                                Text(section.name).font(.system(size: 20.0, weight: .bold))
                                Spacer()
                            }
                            ForEach(section.items) { item in
                                switch item {
                                    case .text(let textItem):
                                        HStack() {
                                            Spacer().frame(width: 20)
                                            TextLabel(text: textItem)
                                            Spacer()
                                        }
                                    case .navLink(let navLinkItem):
                                        HStack() {
                                            Spacer().frame(width: 20)
                                            NavigationLink(destination: XMLDetailView(title: navLinkItem.title, filePath: navLinkItem.filePath)) {
                                            Text(navLinkItem.title)
                                                .foregroundColor(Color(UIColor.systemBlue))
                                            }
                                            Spacer()
                                        }
                                     case .breakSpace(let breakItem):
                                         Spacer().frame(height: breakItem.spacing)
                                }
                            }
                        }
                        Spacer().frame(height: 30)
                    }
                }
                Spacer()
            }
            .onAppear {
                loadXMLData(from: filePath)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
    }
    
    func loadXMLData(from relativePath: String) {
        guard let baseUrl = URL(string: "https://raw.githubusercontent.com/fridakitten/FridaWikiXMLRepo/main/main.xml"),
              let url = URL(string: relativePath, relativeTo: baseUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async {
                hierarchy = parseXML(data: data)
            }
        }.resume()
    }
}
