//
//  EventService.swift
//  TICKEZY
//
//  Created by M.A on 10/15/25.
//

//
//  EventService.swift
//  TICKEZY
//

import SwiftUI
import Foundation
import Combine

@MainActor
class EventService: ObservableObject {
    static let shared = EventService()
    private init() {}

    private let baseURL = "http://localhost:3000/api/events"

    // MARK: - Published properties
    @Published var events: [Event] = []
    @Published var selectedEvent: Event?
    @Published var pagination: Pagination?
    @Published var errorMessage: String?

    // MARK: - Response Structs
    struct EventsResponse: Codable {
        let success: Bool
        let data: [Event]
        let pagination: Pagination
    }

    struct EventResponse: Codable {
        let success: Bool
        let data: Event
    }

    struct Pagination: Codable {
        let total: Int
        let page: Int
        let limit: Int
        let totalPages: Int
    }

    struct BackendErrorResponse: Codable {
        let success: Bool
        let message: String
        let details: [String]?
    }

    // MARK: - Fetch all events
    func fetchEvents(
        page: Int = 1,
        limit: Int = 10,
        category: EventCategory? = nil,
        status: EventStatus? = nil,
        isPublished: Bool? = nil,
        search: String? = nil
    ) async {
        do {
            var queryItems: [URLQueryItem] = [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "limit", value: "\(limit)")
            ]
            if let category { queryItems.append(URLQueryItem(name: "category", value: category.rawValue)) }
            if let status { queryItems.append(URLQueryItem(name: "status", value: status.rawValue)) }
            if let isPublished { queryItems.append(URLQueryItem(name: "isPublished", value: "\(isPublished)")) }
            if let search { queryItems.append(URLQueryItem(name: "search", value: search)) }

            var components = URLComponents(string: baseURL)!
            components.queryItems = queryItems
            guard let url = components.url else { throw URLError(.badURL) }

            print("Fetching events from URL:", url.absoluteString)

            let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
            guard let httpResponse = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }

            print("HTTP Status Code:", httpResponse.statusCode)
            print("Response Data:", String(data: data, encoding: .utf8) ?? "")

            switch httpResponse.statusCode {
            case 200:
                let decoder = JSONDecoder.tickezyDecoder
                let result = try decoder.decode(EventsResponse.self, from: data)
                self.events = result.data
                self.pagination = result.pagination
                print("Fetched events count:", self.events.count)
            default:
                if let errorResponse = try? JSONDecoder().decode(BackendErrorResponse.self, from: data) {
                    self.errorMessage = errorResponse.message
                } else {
                    self.errorMessage = String(data: data, encoding: .utf8)
                }
                self.events = []
            }
        } catch {
            if let urlError = error as? URLError, urlError.code == .cancelled {
                // Ignore benign cancellation (e.g., view disappears or request superseded)
                return
            }
            print("Fetch events error:", error)
            self.errorMessage = error.localizedDescription
            self.events = []
        }
    }


    // MARK: - Fetch single event by ID (Direct Return)
    func getEventById(id: String) async throws -> Event {
        guard let url = URL(string: "\(baseURL)/\(id)") else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        
        guard httpResponse.statusCode == 200 else {
            if let errorResponse = try? JSONDecoder().decode(BackendErrorResponse.self, from: data) {
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
            }
            throw URLError(.badServerResponse)
        }
        
        let result = try JSONDecoder.tickezyDecoder.decode(EventResponse.self, from: data)
        return result.data
    }

    // MARK: - Fetch single event by ID
    func fetchEventById(_ id: String) async {
        do {
            guard let url = URL(string: "\(baseURL)/\(id)") else { throw URLError(.badURL) }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Accept")

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }

            switch httpResponse.statusCode {
            case 200:
                let decoder = JSONDecoder.tickezyDecoder
                let result = try decoder.decode(EventResponse.self, from: data)
                self.selectedEvent = result.data
            default:
                if let errorResponse = try? JSONDecoder().decode(BackendErrorResponse.self, from: data) {
                    self.errorMessage = errorResponse.message
                } else {
                    let message = String(data: data, encoding: .utf8) ?? "Unknown error"
                    self.errorMessage = message
                }
                self.selectedEvent = nil
            }
        } catch {
            if let urlError = error as? URLError, urlError.code == .cancelled {
                // Ignore benign cancellation
                return
            }
            self.errorMessage = error.localizedDescription
            self.selectedEvent = nil
        }
    }

    // MARK: - Admin: Create event
    func createEvent(event: EventInput, token: String) async {
        do {
            guard let url = URL(string: baseURL) else { throw URLError(.badURL) }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.httpBody = try event.toMultipartFormData(boundary: boundary)

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }

            print("Create Event Status Code:", httpResponse.statusCode)
            print("Create Event Response:", String(data: data, encoding: .utf8) ?? "")

            switch httpResponse.statusCode {
            case 201:
                // Success - clear any previous errors
                self.errorMessage = nil
            default:
                // Parse backend error
                if let errorResponse = try? JSONDecoder().decode(BackendErrorResponse.self, from: data) {
                    self.errorMessage = errorResponse.message
                } else {
                    self.errorMessage = String(data: data, encoding: .utf8) ?? "Failed to create event"
                }
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // MARK: - Admin: Update event
    func updateEvent(eventId: String, event: EventInput, token: String) async {
        do {
            guard let url = URL(string: "\(baseURL)/\(eventId)") else { throw URLError(.badURL) }

            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.httpBody = try event.toMultipartFormData(boundary: boundary)

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }

            print("Update Event Status Code:", httpResponse.statusCode)
            print("Update Event Response:", String(data: data, encoding: .utf8) ?? "")

            switch httpResponse.statusCode {
            case 200:
                // Success
                self.errorMessage = nil
            default:
                // Parse backend error
                if let errorResponse = try? JSONDecoder().decode(BackendErrorResponse.self, from: data) {
                    self.errorMessage = errorResponse.message
                } else {
                    self.errorMessage = String(data: data, encoding: .utf8) ?? "Failed to update event"
                }
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // MARK: - Admin: Delete event
    func deleteEvent(eventId: String, token: String) async {
        do {
            guard let url = URL(string: "\(baseURL)/\(eventId)") else { throw URLError(.badURL) }

            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to delete event"])
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Event input for create/update
struct EventInput {
    let title: String
    let description: String
    let location: String
    let eventDate: Date
    let price: Double
    let totalTickets: Int
    let category: EventCategory
    let status: EventStatus
    let isPublished: Bool
    let imageData: Data?

    func toMultipartFormData(boundary: String) throws -> Data {
        var body = Data()

        func appendField(_ name: String, _ value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        appendField("title", title)
        appendField("description", description)
        appendField("location", location)
        appendField("eventDate", ISO8601DateFormatter().string(from: eventDate))
        appendField("price", "\(price)")
        appendField("totalTickets", "\(totalTickets)")
        appendField("category", category.rawValue)
        appendField("status", status.rawValue)
        appendField("isPublished", "\(isPublished)")

        if let imageData {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"event.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
}
