import Models
import SwiftUI

public struct PersonButtonView: View {
    @Binding var isSelected: Bool
    var person: Person
    var onTap: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var backgroundColor: Color {
        isSelected
        ? colorScheme == .light ? .black : .white
        : colorScheme == .light ? .white : .black
    }
    
    var foregroundColor: Color {
        isSelected
        ? colorScheme == .light ? .white : .black
        : colorScheme == .light ? .black : .white
    }
    
    public var body: some View {
        Button {
            onTap()
        } label: {
            HStack {
                Image(systemName: "person")
                Text(person.name)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.borderless)
        .padding()
        .background(backgroundColor)
        .foregroundColor(foregroundColor)
        .clipShape(.capsule)
        .overlay(Capsule()
            .stroke(colorScheme == .light ? .black : .white, lineWidth: 1)
        )
    }
}

#Preview {
    HStack {
        PersonButtonView(
            isSelected: .constant(true),
            person: Person(name: "Blob"),
            onTap: {}
        )
        PersonButtonView(
            isSelected: .constant(false),
            person: Person(name: "Megan"),
            onTap: {}
        )
        PersonButtonView(
            isSelected: .constant(false),
            person: Person(name: "Sid"),
            onTap: {}
        )
    }
}
