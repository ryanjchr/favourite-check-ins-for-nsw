//
//  Quick_Check_In_for_Service_NSWApp.swift
//  Quick Check In for Service NSW
//
//  Created by Ryan Christensen on 30/6/21.
//

import SwiftUI

@main
struct Quick_Check_In_for_Service_NSWApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
