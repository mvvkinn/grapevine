//
//  Encodable.swift
//  Grapevine
//
//  Created by 김민우 on 2022/12/17.
//

import Foundation


extension Encodable {
    var asDictionary: [String: Any]? {
        guard let object = try? JSONEncoder().encode(self),
              let dictionary = try? JSONSerialization.jsonObject(with: object, options: []) as? [String: Any] else {return nil}
        return dictionary
    }
}
