//
//  StringEx.swift
//  BuffettoMungology
//
//  Created by Anthony Ezeh on 13/07/2019.
//  Copyright © 2019 Gallivanter. All rights reserved.
//

import Foundation

extension String
{
    public func trim() -> String!
    {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}
