//
//  ContentView.swift
//  UMEE Beyond the waves
//
//  Created by quantum on 08.06.2023.
//

import SwiftUI

struct ContentView: View {
    @State private var delaySec = String(prefs.delaySec)
    @State private var autostart = prefs.autostart
    @State private var selectedTicker = prefs.ticker
    @State private var selectedPngUrl = prefs.pngPath
    
    // data arrays
    var tickers = [String]()
    var addresses = [String]()
    var pngUrls = [String]()
    
    init() {
        for coin in Prefs.Immutable.coinData
        {
            tickers.append(coin[0])
            pngUrls.append(coin[1])
        }
    }
    
    var body: some View {
        ZStack {
            VStack{
                Group {
                    Text("Coin Ticker Name:")
                        .frame(height: 20)
                        .font(.custom("Menlo", size: 13))
                    Picker("", selection: $selectedTicker) {
                        ForEach(tickers, id: \.self) {Text($0)}
                    }
                    .frame(width: 360, height: 20)
                    .labelsHidden()
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: selectedTicker) {newValue in
                        let index = tickers.firstIndex(of: selectedTicker)
                        selectedPngUrl = pngUrls[index!]
                    }
                }
                
                Group {
                    Text("Interval Between Requests:")
                        .frame(height: 20)
                        .font(.custom("Menlo", size: 13))
                    TextField(" 60 < Interval < 3600, in seconds", text: $delaySec)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        .frame(width: 390, height: 25)
                }
                .multilineTextAlignment(.center)
                
                Group {
                    Toggle(isOn: $autostart) {
                        Text("Start With System")
                    }
                    .frame(height: 22)
                    .font(.custom("Menlo", size: 13))
                    HStack {
                        Button("Save changes") {
                            if (!check_data(delaySec: delaySec)) {
                                save_prefs(delaySec: Double(delaySec)!, pngPath: selectedPngUrl, ticker: selectedTicker, autostart: autostart)
                            }
                            else {
                                delaySec = ""
                            }
                        }
                        .padding()
                        .frame(width: 150, height: 30)
                        .font(.custom("Menlo", size: 12))
                        
                        Button ("Exit widget ") {
                            exit(0)
                        }
                        .frame(width: 150, height: 30)
                        .font(.custom("Menlo", size: 12))
                    }
                    .padding(.bottom, 8)
                }
                Text("Dive right in,\nfriend")
                    .font(.custom("Menlo", size: 22))
                    .frame(width: 300, height: 70)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
            }
            }
        .frame(width: 380, height: 380, alignment: Alignment.center)
            .background(
                Image("poster")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .blur(radius: 2)
                    .contrast(0.4)
                    .brightness(-0.1)
            )
        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
