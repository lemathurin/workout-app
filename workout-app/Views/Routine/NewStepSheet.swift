import SwiftUI

struct NewStepSheet: View {
    @State private var selectedStepType: StepType = .exercise
    
    var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Toggle("Exercise", isOn: Binding(
                        get: { selectedStepType == .exercise },
                        set: { if $0 { selectedStepType = .exercise } }
                    ))
                    .toggleStyle(.button)
                    
                    Toggle("Rest", isOn: Binding(
                        get: { selectedStepType == .rest },
                        set: { if $0 { selectedStepType = .rest } }
                    ))
                    .toggleStyle(.button)
                    
                    Toggle("Repeat", isOn: Binding(
                        get: { selectedStepType == .repeats },
                        set: { if $0 { selectedStepType = .repeats } }
                    ))
                    .toggleStyle(.button)
                Spacer()
                }
                Spacer()
            }.padding()
        }
}

#Preview {
    NewStepSheet()
}
