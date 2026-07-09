import SwiftUI

struct SetupView: View {
    @Bindable var model: DemoFlowModel
    @State private var pin = ""

    var body: some View {
        Form {
            Section("Auth Token") {
                LabeledContent {
                    Text(model.session.authToken)
                        .font(.footnote)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } label: {
                    Text("Auth Token: ")
                }
            }

            Section("Create Session") {
                LabeledContent("Contact Email: ") {
                    TextField("", text: $model.session.contactEmail, prompt: Text("contact@example.com"))
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                }
                Button(model.isBusy ? "Creating…" : "Create Session") {
                    Task { await model.createSession() }
                }
                .disabled(model.isBusy)
            }

            Section("Retrieve Session") {
                LabeledContent("PIN: ") {
                    TextField("", text: $pin, prompt: Text("Required"))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
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
