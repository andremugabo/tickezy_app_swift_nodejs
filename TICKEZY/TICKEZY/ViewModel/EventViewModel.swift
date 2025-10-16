//
//  ViewModel.swift
//  TICKEZY
//
//  Created by M.A on 10/16/25.
//




import Foundation
import SwiftUI
import Combine

@MainActor
class EventViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var selectedCategory: EventCategory?
    @Published var selectedStatus: EventStatus?
    @Published var searchText: String = ""
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""

    private let service = EventService.shared

    func fetchEvents() async {
        do {
            await service.fetchEvents(
                category: selectedCategory,
                status: selectedStatus,
                search: searchText.isEmpty ? nil : searchText
            )
            self.events = service.events
        } catch {
            self.errorMessage = service.errorMessage ?? error.localizedDescription
            self.showError = true
        }
    }
}
