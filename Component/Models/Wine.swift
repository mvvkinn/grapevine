//
//  Wine.swift
//  Grapevine
//
//  Created by 김민우 on 2022/12/17.
//

import Foundation

struct Wine: Codable {
    let name: String
    let country: String
    let alcohol: Float16
    let features: String
    
    init(name: String, country: String, alcohol: Float16, features: String) {
        self.country = country
        self.alcohol = alcohol
        self.features = features
        self.name = name
    }
}

