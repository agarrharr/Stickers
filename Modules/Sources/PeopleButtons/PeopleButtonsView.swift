//import IdentifiedCollections
//import SwiftUI
//
//public struct PeopleButtonsView: View {
//    var people: IdentifiedArrayOf<Person>
//    var onTap: (Person) -> Void
//    
//    @State private var selectedPersonId: UUID? = nil
//    
//    public init(people: IdentifiedArrayOf<Person>, onTap: @escaping (Person) -> Void, selectedPersonId: UUID? = nil) {
//        self.people = people
//        self.onTap = onTap
//        self.selectedPersonId = selectedPersonId
//    }
//    
//    public var body: some View {
//        ScrollView(.horizontal) {
//            HStack {
//                Spacer()
//                    .frame(width: 20)
//                ForEach(people, id: \.id) { person in
//                    PersonButtonView(
//                        isSelected: Binding(
//                            get: {
//                                guard let selectedPersonId else {
//                                    return false
//                                }
//                                return selectedPersonId == person.id
//                            },
//                            set: { _ in }
//                        ),
//                        person: person,
//                        onTap: {
//                            if selectedPersonId == person.id {
//                                selectedPersonId = nil
//                            } else {
//                                selectedPersonId = person.id
//                            }
//                            onTap(person)
//                        })
//                }
//                Spacer()
//            }
//        }
//        .scrollIndicators(.hidden)
//    }
//}
//
//struct PersonButtonView: View {
//    @Binding var isSelected: Bool
//    var person: Person
//    var onTap: () -> Void
//    
//    @Environment(\.colorScheme) var colorScheme
//    
//    var backgroundColor: Color {
//        isSelected
//        ? colorScheme == .light ? .black : .white
//        : colorScheme == .light ? .white : .black
//    }
//    
//    var foregroundColor: Color {
//        isSelected
//        ? colorScheme == .light ? .white : .black
//        : colorScheme == .light ? .black : .white
//    }
//    
//    var body: some View {
//        Button {
//            onTap()
//        } label: {
//            HStack {
//                Image(systemName: "person")
//                Text(person.name)
//                    .lineLimit(1)
//            }
//        }
//        .buttonStyle(.borderless)
//        .padding()
//        .background(backgroundColor)
//        .foregroundColor(foregroundColor)
//        .clipShape(.capsule)
//        .overlay(Capsule()
//            .stroke(colorScheme == .light ? .black : .white, lineWidth: 1)
//        )
//        .padding(1)
//    }
//}
//
//#Preview {
//    PeopleButtonsView(
//        people: [
//            Person(name: "Blob"),
//            Person(name: "Megan"),
//            Person(name: "Sid"),
//        ],
//        onTap: { _ in }
//    )
//}
//
//#Preview {
//    HStack {
//        PersonButtonView(
//            isSelected: .constant(true),
//            person: Person(name: "Blob"),
//            onTap: {}
//        )
//        PersonButtonView(
//            isSelected: .constant(false),
//            person: Person(name: "Megan"),
//            onTap: {}
//        )
//        PersonButtonView(
//            isSelected: .constant(false),
//            person: Person(name: "Sid"),
//            onTap: {}
//        )
//    }
//}
