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
    @Published var errorMessage: String?

    // Loading & pagination
    @Published var isLoading: Bool = false
    @Published var hasMorePages: Bool = true
    private var page: Int = 1
    private let limit: Int = 10

    private let service = EventService.shared

    func fetchEvents() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        // Fetch from service with pagination & filters
        await service.fetchEvents(
            page: page,
            limit: limit,
            category: selectedCategory,
            status: selectedStatus,
            search: searchText.isEmpty ? nil : searchText
        )

        // Update local state
        if page == 1 {
            self.events = service.events
        } else {
            self.events += service.events
        }

        if let pagination = service.pagination {
            self.hasMorePages = page < pagination.totalPages
        } else {
            // Fallback: if returned less than limit, probably last page
            self.hasMorePages = service.events.count == limit
        }

        if let error = service.errorMessage {
            self.errorMessage = error
            self.showError = true
        }
    }

    func loadNextPage() async {
        guard hasMorePages, !isLoading else { return }
        page += 1
        await fetchEvents()
    }

    func refresh() async {
        page = 1
        hasMorePages = true
        events = []
        await fetchEvents()
    }

    func clearFilters() {
        selectedCategory = nil
        selectedStatus = nil
    }

    func clearError() {
        showError = false
        errorMessage = nil
    }
}
