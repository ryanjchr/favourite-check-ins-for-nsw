//
//  ContentView.swift
//  Quick Check In for Service NSW
//
//  Created by Ryan Christensen on 30/6/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var showingSheet = false
    @State private var lastSavedBusiness: COVIDBusiness? = nil
    @State private var lastSavedBusinessAleradyExists: COVIDBusiness? = nil
    @State private var showingAlertSavedBusiness: AlertIdentifiable? = nil
    @State private var errorAlert: AlertIdentifiable? = nil
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(key: "order", ascending: false)],
        animation: .default)
    private var items: FetchedResults<ServiceNSWCovidBusiness>
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(items) { item in
                        VStack(alignment: .leading) {
                            Text(item.name)
                            Text(item.address).font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }.onTapGesture {
                            UIApplication.shared.open(URL(string: item.url)!)
                        }
                    }
                    .onDelete(perform: deleteItems)
                    .onMove(perform: moveItem)
                }.listStyle(PlainListStyle())
                .toolbar {
                    EditButton()
                }.navigationBarTitle(Text("Favourite Venues"), displayMode: .automatic)
                VStack {
                    Button(action: { showingSheet.toggle() }) {
                        Label("Scan Service NSW QR Code", systemImage: "qrcode")
                    }
                }.padding()
            }.sheet(isPresented: $showingSheet, onDismiss: {
                if (self.lastSavedBusiness != nil) {
                    let name = self.lastSavedBusiness!.name
                    let url = self.lastSavedBusiness!.url
                    self.showingAlertSavedBusiness = AlertIdentifiable(
                        message: "\(name) has been saved to your favourite venues list. Would you like to check in to this venue right now?",
                        title: "Venue Saved",
                        onAction: {
                            UIApplication.shared.open(URL(string: url)!)
                        },
                        onDismiss: {
                            self.lastSavedBusiness = nil
                        }
                    )
                } else if (self.lastSavedBusinessAleradyExists != nil) {
                    let name = self.lastSavedBusinessAleradyExists!.name
                    let url = self.lastSavedBusinessAleradyExists!.url
                    self.showingAlertSavedBusiness = AlertIdentifiable(
                        message: "\(name) already exists in your favourite venues list. Would you like to check in to this venue right now?",
                        title: "Venue Already Saved",
                        onAction: {
                            UIApplication.shared.open(URL(string: url)!)
                        },
                        onDismiss: {
                            self.lastSavedBusinessAleradyExists = nil
                        }
                    )
                }
            }) {
                ScannerView(onScan: { url in
                    do {
                        let businessInfo = try processServiceNSWURL(url: url)
                        addItem(s: businessInfo)
                    } catch let error {
                        switch error {
                        case QRCodeError.internalRegexError:
                            self.errorAlert = AlertIdentifiable(message: "The app couldn't prepare a Regular Expression to match the QR code data.", title: nil, onAction: nil, onDismiss: nil)
                        case QRCodeError.notServiceNSWQRCode:
                            self.errorAlert = AlertIdentifiable(message: "The QR code does not appear to be a Service NSW QR code.", title: nil, onAction: nil, onDismiss: nil)
                        case QRCodeError.noDataInServiceNSWURL:
                            self.errorAlert = AlertIdentifiable(message: "Couldn't find any relevant data in the Service NSW QR code. Try scanning again.", title: nil, onAction: nil, onDismiss: nil)
                        case QRCodeError.nonCovid19ServiceNSWQRCode:
                            self.errorAlert = AlertIdentifiable(message: "The QR code does not appear to be for COVID check-in purposes. Check you have scanned the correct QR code and try again.", title: nil, onAction: nil, onDismiss: nil)
                        default:
                            self.errorAlert = AlertIdentifiable(message: "An internal error occurred while attempting to verify and record the QR code data.", title: nil, onAction: nil, onDismiss: nil)
                        }
                    }
                })
            }.alert(item: $errorAlert) { item in
                return Alert(title: Text(item.title ?? "Error"), message: Text(item.message), dismissButton: .default(Text("OK")) {
                    if (item.onDismiss != nil) {
                        item.onDismiss!()
                    }
                })
            }.alert(item: $showingAlertSavedBusiness) { item in
                return Alert(
                    title: Text(item.title ?? "Venue Saved"),
                    message: Text(item.message),
                    primaryButton: .default(Text("Check In")) {
                        if (item.onDismiss != nil) {
                            item.onDismiss!()
                        }
                        if (item.onAction != nil) {
                            item.onAction!()
                        }
                    },
                    secondaryButton: .cancel(Text("Not Now")) {
                        if (item.onDismiss != nil) {
                            item.onDismiss!()
                        }
                    }
                )
            }
        }
    }
    
    private func addItem(s: COVIDBusiness) {
        withAnimation {
            let business = COVIDBusiness(id: s.id, url: s.url, name: s.name, address: s.address)
            if (items.firstIndex(where: { $0.id == s.id }) != nil) {
                self.lastSavedBusinessAleradyExists = business
            } else {
                let newItem = ServiceNSWCovidBusiness(context: viewContext)
                newItem.url = s.url
                newItem.name = s.name
                newItem.address = s.address
                newItem.order = (items.first?.order ?? 0) + 1
                newItem.id = s.id
                self.lastSavedBusiness = business
                do {
                    try viewContext.save()
                    addServiceNSWCovidBusinessToSpotlight(business: business)
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
            self.showingSheet.toggle()
        }
    }
    
    private func moveItem(offsets: IndexSet, destinationIndex: Int) {
        let originIndex = offsets.first!
        if (originIndex == destinationIndex) {
            return
        }
        var index = originIndex < destinationIndex ? originIndex + 1 : destinationIndex
        let endIndex = (originIndex < destinationIndex ? destinationIndex : originIndex) - 1
        var itemPosition = originIndex < destinationIndex ? items[ originIndex].order : items[destinationIndex].order - 1
        while index <= endIndex {
            items[index].order = itemPosition
            itemPosition -= 1
            index += 1
        }
        items[originIndex].order = originIndex < destinationIndex ? itemPosition : items[destinationIndex].order + 1
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach{ item in
                viewContext.delete(item)
                removeServiceNSWCovidBusinessFromSpotlight(url: item.url)
            }
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
