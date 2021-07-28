//
//  ProcessServiceNSWURL.swift
//  Quick Check In for Service NSW
//
//  Created by Ryan Christensen on 10/7/21.
//

import Foundation

enum QRCodeError: Error {
    case internalRegexError
    case notServiceNSWQRCode
    case noDataInServiceNSWURL
    case nonCovid19ServiceNSWQRCode
}

struct COVIDBusiness {
    let id: String
    let url: String
    let name: String
    let address: String
}

func processServiceNSWURL(url: String) throws -> COVIDBusiness {
    guard let regex = try? NSRegularExpression(pattern: "https://www\\.service\\.nsw\\.gov\\.au/campaign/service-nsw-mobile-app\\?data=(.*)", options: .caseInsensitive) else {
        throw QRCodeError.internalRegexError
    }
    
    guard let match = regex.firstMatch(in: url, options: [], range: NSRange(location: 0, length: url.utf16.count))  else {
        throw QRCodeError.notServiceNSWQRCode
    }
    
    guard let b64Range = Range(match.range(at: 1), in: url) else {
        throw QRCodeError.noDataInServiceNSWURL
    }
    
    let b64String = String(url[b64Range]);
    guard let decodedData = Data(base64Encoded: b64String) else {
        throw QRCodeError.noDataInServiceNSWURL
    }
    
    do {
        let decodedString = String(data: decodedData, encoding: .utf8)!
        guard let json = try? JSONSerialization.jsonObject(with: Data(decodedString.utf8), options: []) as? [String: String] else {
            throw QRCodeError.noDataInServiceNSWURL
        }
        guard let qrCodeType = json["t"] else {
            throw QRCodeError.noDataInServiceNSWURL
        }
        if (qrCodeType != "covid19_business") {
            throw QRCodeError.nonCovid19ServiceNSWQRCode
        }
        guard let id = json["bid"] else {
            throw QRCodeError.noDataInServiceNSWURL
        }
        guard let name = json["bname"] else {
            throw QRCodeError.noDataInServiceNSWURL
        }
        guard let address = json["baddress"] else {
            throw QRCodeError.noDataInServiceNSWURL
        }
        let info = COVIDBusiness(id: id, url: url, name: name, address: address)
        return info
    } catch let error as NSError {
        throw error
    }
}
