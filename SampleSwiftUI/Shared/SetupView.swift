import SwiftUI

struct SetupView: View {
    @Bindable var model: DemoFlowModel
    @State private var pin = ""

    var body: some View {
        Form {
            Section("Auth Token") {
                Text(model.session.authToken)
                    .font(.footnote)
                    .textSelection(.enabled)
            }

            Section("Create Session") {
                TextField("Contact Email", text: $model.session.contactEmail)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                Button(model.isBusy ? "Creating…" : "Create Session") {
                    Task { await model.createSession() }
                }
                .disabled(model.isBusy)
            }

            Section("Retrieve Session") {
                TextField("PIN", text: $pin)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                Button(model.isBusy ? "Retrieving…" : "Retrieve Session") {
                    Task { await model.retrieveSession(pin: pin) }
                }
                .disabled(model.isBusy || pin.isEmpty)
            }

            if let errorMessage = model.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Setup Session")
    }
}
