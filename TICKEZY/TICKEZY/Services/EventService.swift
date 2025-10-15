//
//  EventService.swift
//  TICKEZY
//
//  Created by M.A on 10/15/25.
//

import SwiftUI
import Foundation
import Combine

@MainActor
class EventService: ObservableObject {
    static let shared = EventService()
    private init() {}
}
