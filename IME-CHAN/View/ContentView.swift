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
        ZStack {
            if let image = imeViewModel.buffImage {
                Image(uiImage: image)
                    .padding(.leading, 1)
                    .frame(width: 896, height: 414)
                    //.scaledToFit()
            }
            
            VStack(spacing: 38) {
                if imeViewModel.showInfo {
                    Text(imeViewModel.recognizedText)
                    .fontWeight(.bold)
                    .font(.largeTitle)
                    .frame(width: 680, height: 191, alignment: .topLeading)

                    HStack(spacing: 14.67) {
                        Text(imeViewModel.expectWord[0])
                        .fontWeight(.bold)
                        .font(.title2)
                        .foregroundColor(Color(#colorLiteral(red: 0.31, green: 0.31, blue: 0.31, alpha: 1)))
                        .multilineTextAlignment(.center)
                        .frame(width: 127, height: 42)
                        .padding(.vertical, 8)
                        .padding(.leading, 15)
                        .padding(.trailing, 17)
                        .frame(width: 159, height: 58)
                        .background(Color.white)
                        .cornerRadius(8)
                        .frame(width: 159, height: 58)

                        Text(imeViewModel.expectWord[1])
                        .fontWeight(.bold)
                        .font(.title2)
                        .foregroundColor(Color(#colorLiteral(red: 0.31, green: 0.31, blue: 0.31, alpha: 1)))
                        .multilineTextAlignment(.center)
                        .frame(width: 127, height: 42)
                        .padding(.vertical, 8)
                        .padding(.leading, 14)
                        .padding(.trailing, 18)
                        .frame(width: 159, height: 58)
                        .background(Color.white)
                        .cornerRadius(8)
                        .frame(width: 159, height: 58)

                        Text(imeViewModel.expectWord[2])
                        .fontWeight(.bold)
                        .font(.title2)
                        .foregroundColor(Color(#colorLiteral(red: 0.31, green: 0.31, blue: 0.31, alpha: 1)))
                        .multilineTextAlignment(.center)
                        .frame(width: 127, height: 42)
                        .padding(.vertical, 8)
                        .padding(.leading, 17)
                        .padding(.trailing, 15)
                        .frame(width: 159, height: 58)
                        .background(Color.white)
                        .cornerRadius(8)
                        .frame(width: 159, height: 58)

                        Text(imeViewModel.expectWord[3])
                        .fontWeight(.bold)
                        .font(.title2)
                        .foregroundColor(Color(#colorLiteral(red: 0.31, green: 0.31, blue: 0.31, alpha: 1)))
                        .multilineTextAlignment(.center)
                        .frame(width: 127, height: 42)
                        .padding(.vertical, 8)
                        .padding(.leading, 14)
                        .padding(.trailing, 18)
                        .frame(width: 159, height: 58)
                        .background(Color.white)
                        .cornerRadius(8)
                        .frame(width: 159, height: 58)
                    }
                    .frame(width: 680, height: 58)
                }
            }
            .padding(.leading, 67)
            .padding(.trailing, 65)
            .padding(.top, 42)
            .padding(.bottom, 46)
            .frame(width: 896, height: 436)
            .background(LinearGradient(gradient: Gradient(colors: [Color(red: 0.56, green: 0.62, blue: 0.67, opacity: 0.4), Color(red: 0.91, green: 0.94, blue: 0.95, opacity: 0.4)]), startPoint: .top, endPoint: .bottom))
            
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
