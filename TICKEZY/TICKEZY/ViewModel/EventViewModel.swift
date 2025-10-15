//
//  ViewModel.swift
//  TICKEZY
//
//  Created by M.A on 10/16/25.
//




import SwiftUI
import Combine

@MainActor
class EventViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var selectedEvent: Event?
    @Published var pagination: EventService.Pagination?
    
    // Error handling
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    private var service = EventService.shared
    
    // Filters
    @Published var selectedCategory: EventCategory? = nil
    @Published var selectedStatus: EventStatus? = nil
    @Published var searchText: String = ""
    
    // Pagination
    @Published var page: Int = 1
    @Published var limit: Int = 10
    
    // MARK: - Fetch Events
    func fetchEvents() async {
        do {
            try await service.fetchEvents(
                page: page,
                limit: limit,
                category: selectedCategory,
                status: selectedStatus,
                isPublished: true,
                search: searchText.isEmpty ? nil : searchText
            )
            self.events = service.events
            self.pagination = service.pagination
        } catch {
            self.errorMessage = error.localizedDescription
            self.showError = true
        }
    }
    
    // MARK: - Fetch Single Event
    func fetchEventById(_ id: String) async {
        do {
            try await service.fetchEventById(id)
            self.selectedEvent = service.selectedEvent
        } catch {
            self.errorMessage = error.localizedDescription
            self.showError = true
        }
    }
}
