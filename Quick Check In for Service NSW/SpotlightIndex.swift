//
//  SpotlightIndex.swift
//  Quick Check In for Service NSW
//
//  Created by Ryan Christensen on 28/7/21.
//

import Foundation
import CoreSpotlight
import MobileCoreServices
import SwiftUI

func addServiceNSWCovidBusinessToSpotlight(business: COVIDBusiness) {
    // Create an attribute set to describe an item.
    let attributeSet = CSSearchableItemAttributeSet(itemContentType: "Ryan-Christensen.Quick-Check-In-for-Service-NSW")
    // Add metadata that supplies details about the item.
    attributeSet.title = "Check in to \(business.name)"
    attributeSet.contentDescription = "Quickly check in to \(business.name) with Service NSW"
    attributeSet.contentType = kUTTypeText as String
    attributeSet.identifier = business.url
    attributeSet.relatedUniqueIdentifier = business.url
    attributeSet.url = URL(string: business.url)
    
    // Create an item with a unique identifier, a domain identifier, and the attribute set you created earlier.
    let item = CSSearchableItem(uniqueIdentifier: business.url, domainIdentifier: "nswcovidbusinesses", attributeSet: attributeSet)
    
    item.expirationDate = Date(timeIntervalSinceNow: 60 * 60 * 24 * 365 * 3) // 3 years, god help us if this is still going on then...
     
    // Add the item to the on-device index.
    CSSearchableIndex.default().indexSearchableItems([item]) { error in
        if error != nil {
            print(error?.localizedDescription)
        }
        else {
            print("Item indexed: \(item.uniqueIdentifier)")
        }
    }
}

func removeServiceNSWCovidBusinessFromSpotlight(url: String) {
    CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [url]) { error in
        if error != nil {
            print(error?.localizedDescription)
        }
        else {
            print("Item removed from index: \(url)")
        }
    }
}

func handleLaunchFromSpotlight(_ userActivity: NSUserActivity) {
    if let itemIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
        UIApplication.shared.open(URL(string: itemIdentifier)!)
    }
}
