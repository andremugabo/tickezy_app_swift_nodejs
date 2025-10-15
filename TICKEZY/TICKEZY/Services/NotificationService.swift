//
//  NotificationService.swift
//  TICKEZY
//
//  Created by M.A on 10/15/25.
//

import SwiftUI
import Foundation
import Combine


@MainActor
class NotificationService: ObservableObject {
    static let shared = NotificationService()
    private init() {}
}
