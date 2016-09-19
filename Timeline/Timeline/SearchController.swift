//
//  SearchController.swift
//  Timeline
//
//  Created by Justin Carver on 9/14/16.
//  Copyright © 2016 Justin Carver. All rights reserved.
//

import Foundation

protocol SearchableRecord {
    func matchesSearchTerm(searchTerm: String) -> Bool
}
