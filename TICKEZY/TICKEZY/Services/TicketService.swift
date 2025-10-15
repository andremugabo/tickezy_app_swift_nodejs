//
//  TicketService.swift
//  TICKEZY
//
//  Created by M.A on 10/15/25.
//

import SwiftUI
import Foundation
import Combine


@MainActor
class TicketService: ObservableObject {
    static let shared = TicketService()
    private init() {}
}
