// Fixture: what an agent typically produces without the pack. The linter must flag it.
import SwiftUI

struct GenericDashboard: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                HStack {
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                    }
                    Spacer()
                    Text("Dashboard").font(.system(size: 22, weight: .bold))
                    Spacer()
                    Button {
                    } label: {
                        Image(systemName: "line.3.horizontal")
                    }
                }
                .padding(.top, 44)

                Text("Welcome back, John Doe! 👋")
                    .font(.system(size: 20, weight: .bold))

                HStack {
                    StatTile(icon: "flame", value: "1,234", label: "Calories")
                    StatTile(icon: "figure.walk", value: "8,500", label: "Steps")
                }
                HStack {
                    StatTile(icon: "moon", value: "7h", label: "Sleep")
                    StatTile(icon: "drop", value: "6", label: "Water")
                }

                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)

                Button("Get Started") {}
                    .font(.system(size: 18, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
}

struct StatTile: View {
    let icon: String
    let value: String
    let label: String
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(Color.blue)
                .padding(10)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            Text(value).font(.system(size: 24, weight: .bold))
            Text(label).font(.system(size: 13)).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .shadow(color: .black.opacity(0.05), radius: 2)
        .shadow(color: Color(red: 0, green: 0, blue: 0.2).opacity(0.05), radius: 16)
    }
}
