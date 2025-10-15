//
//  ViewModel.swift
//  TICKEZY
//
//  Created by M.A on 10/16/25.
//

import Foundation
import Combine

@MainActor
class EventViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    static let shared = EventViewModel()
    private init() {}

    func fetchEvents() async {
        isLoading = true
        errorMessage = nil
        do {
            let fetchedEvents = try await EventService.shared.fetchEvents()
            events = fetchedEvents
        } catch {
            errorMessage = "Failed to load events: \(error.localizedDescription)"
            events = []
        }
        isLoading = false
    }
}
