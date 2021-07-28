//
//  ScannerView.swift
//  Quick Check In for Service NSW
//
//  Created by Ryan Christensen on 28/7/21.
//

import Foundation
import SwiftUI

struct ScannerView: View {
    var onScan: (String) -> ()
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel = ScannerViewModel()
    
    var body: some View {
        ZStack {
            QrCodeScannerView()
                .found(r: onScan)
                .torchLight(isOn: self.viewModel.torchIsOn)
                .interval(delay: self.viewModel.scanInterval)
            
            
            VStack {
                VStack {
                    Text("Scanning for Service NSW QR codes...")
                        .font(.subheadline)
                }
                .padding(.vertical, 20)
                
                Spacer()
                HStack {
                    Button(action: {
                        self.viewModel.torchIsOn.toggle()
                    }, label: {
                        Image(systemName: self.viewModel.torchIsOn ? "bolt.fill" : "bolt.slash.fill")
                            .imageScale(.large)
                            .foregroundColor(self.viewModel.torchIsOn ? Color.yellow : Color.blue)
                            .padding()
                    })
                }
                .background(Color.white)
                .cornerRadius(10)
                
            }.padding()
        }
    }
}
