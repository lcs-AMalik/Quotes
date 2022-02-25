//
//  Quote.swift
//  Quotes
//
//  Created by Abdul Malik on 2022-02-22.
//

import Foundation

// The DadJoke structure conforms to the
// Decodable protocol. This meanse that we want
// Swift to be able to take a JSON object
// and 'decode' into an instance of this
// structure
// "Hashable" protocol conformance - just means that swift
// will be able to quickly determine when one instance of this
// data type differs from another.
struct Quote: Decodable, Hashable, Encodable {
    let quoteText: String
    let quoteAuthor: String
    let senderName: String
    let senderLink: String
    let quoteLink: String
}


