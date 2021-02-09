//
//  ContentView.swift
//  RentateamTest
//
//  Created by Denis Larin on 09.02.2021.
//

import SwiftUI
import Foundation
import CoreData


struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @State var posts = [Post]()
    
    
    
    var body: some View {
        NavigationView{List(posts, id: \.id) { post in
            NavigationLink(destination: DetailView(post: post)) {
                
                HStack() {
                    
                    RemoteImage(url: post.url)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 150)
                                .cornerRadius(20)
                    Text(String(describing: post.id))
                        .font(.headline)
                    Text(String(describing: post.title))
                        .font(.headline)
                }
                
            }.navigationBarTitle("Picture Viewer")
        }.onAppear(perform: loadData)
        }
    }
}


struct DetailView: View {
    var post: Post
    let date = Date().europeanFormattedEn_US
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(post.title)
                .font(.headline)
            RemoteImage(url: post.url)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300)
                        .cornerRadius(40)
            Text(String(describing: date))
        }
    }
}


struct Post: Decodable {
    var id: Int
    var title: String
    var url: String
    var thumbnailUrl: String
}


extension ContentView
{
    func loadData() {
        
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/photos") else {
            return
        }
        
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let data = data {
                if let response_obj = try? JSONDecoder().decode([Post].self, from: data) {
                    
                    DispatchQueue.main.async {
                        self.posts = response_obj
                    }
                }
            }
            
        }.resume()
        saveContext()
    }
    func saveContext() {
      do {
        try managedObjectContext.save()
      } catch {
        print("Error saving managed object context: \(error)")
      }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension Formatter {
    static let date = DateFormatter()
}
extension Date {
    var europeanFormattedEn_US : String {
        Formatter.date.calendar = Calendar(identifier: .iso8601)
        Formatter.date.locale   = Locale(identifier: "en_US_POSIX")
        Formatter.date.timeZone = .current
        Formatter.date.dateFormat = "dd/M/yyyy"
        return Formatter.date.string(from: self)
    }
}
