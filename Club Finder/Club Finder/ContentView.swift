//
//  ContentView.swift
//  Club Finder
//
//  Created by Jake Treska on 10/26/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        CustomController()
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
//            Text("Hello, world!")
//        }
//        .padding()
    }
}

struct ContentView_Previews: PreviewProvider{
    static var previews: some View{
        ContentView()
    }
}


struct CustomController: UIViewControllerRepresentable{
    func makeUIViewController(context: Context) -> UIViewController {
        let storyboard = UIStoryboard(name:"Main",bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(withIdentifier: "Screen1")
        return controller
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        //
    }
}

#Preview {
    ContentView()
}


