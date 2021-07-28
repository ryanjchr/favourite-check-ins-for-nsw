//
//  ServiceNSWCovidBusiness.swift
//  Quick Check In for Service NSW
//
//  Created by Ryan Christensen on 10/7/21.
//

import CoreData

class ServiceNSWCovidBusiness: NSManagedObject, Identifiable {
    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var address: String
    @NSManaged var url: String
    @NSManaged var order: Int
}
