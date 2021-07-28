//
//  AlertIdentifiable.swift
//  Quick Check In for Service NSW
//
//  Created by Ryan Christensen on 28/7/21.
//
import SwiftUI
import Foundation

class AlertIdentifiable: Identifiable {
    let title: String?
    let message: String
    let onAction: (() -> Void)?
    let onDismiss: (() -> Void)?
    
    init(message: String, title: String?, onAction: (() -> Void)?, onDismiss: (() -> Void)?) {
        self.title = title
        self.message = message
        self.onAction = onAction
        self.onDismiss = onDismiss
    }
}
