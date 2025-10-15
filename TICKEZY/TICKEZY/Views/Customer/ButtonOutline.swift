import SwiftUI

struct ButtonOutline: View {
    let title: String
    let iconName: String? // optional SF Symbol name
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let iconName = iconName {
                    Image(systemName: iconName)
                        .foregroundColor(.brandBlue)
                }

                Text(title)
                    .font(.headline)
                    .foregroundColor(.brandBlue)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.brandBlue, lineWidth: 2)
            )
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ButtonOutline(title: "Login", iconName: "person.fill") {}
        ButtonOutline(title: "Sign Up", iconName: "plus.circle") {}
        ButtonOutline(title: "No Icon", iconName: nil) {}
    }
    .padding()
    
}
