//
//  ContentView.swift
//  IME-CHAN
//
//  Created by Rei Nakaoka on 2021/11/20.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @ObservedObject var imeViewModel = IMEViewModel()

    var body: some View {
        VStack {
            if let image = imeViewModel.buffImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
            HStack {
                Button("run") { imeViewModel.runVideo() }
                Button("stop") { imeViewModel.stopVideo() }
            }
            .font(.largeTitle)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
