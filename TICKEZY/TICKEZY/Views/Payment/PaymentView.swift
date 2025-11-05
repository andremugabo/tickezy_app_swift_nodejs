//
//  PaymentView.swift
//  TICKEZY
//
//  Created by M.A on 11/4/25.
//

import SwiftUI

struct PaymentView: View {
    @StateObject private var paymentService = PaymentService.shared
    @EnvironmentObject var auth: AuthService
    @State private var selectedPayment: Payment?
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()
                
                if isLoading {
                    loadingView
                } else if paymentService.payments.isEmpty {
                    emptyStateView
                } else {
                    paymentsList
                }
            }
            .navigationTitle("My Payments")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await loadPayments()
            }
            .sheet(item: $selectedPayment) { payment in
                PaymentDetailView(payment: payment)
            }
            .task {
                await loadPayments()
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.brandPrimary)
                .scaleEffect(1.2)
            Text("Loading payments...")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
        }
    }
    
    private var paymentsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(paymentService.payments) { payment in
                    Button {
                        selectedPayment = payment
                    } label: {
                        PaymentCardView(payment: payment)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "creditcard")
                .font(.system(size: 60))
                .foregroundColor(.textTertiary)
            
            Text("No Payments Yet")
                .font(.title2.bold())
                .foregroundColor(.textPrimary)
            
            Text("Make your first purchase to see payments here")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
            
            NavigationLink {
                EventView()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "calendar.badge.plus")
                    Text("Browse Events")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [Color.brandPrimary, Color.brandSecondary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 40)
    }
    
    private func loadPayments() async {
        guard let token = auth.token else {
            isLoading = false
            return
        }
        
        isLoading = true
        await paymentService.fetchPayments(token: token)
        isLoading = false
    }
}

#Preview {
    PaymentView()
        .environmentObject(AuthService.shared)
}
