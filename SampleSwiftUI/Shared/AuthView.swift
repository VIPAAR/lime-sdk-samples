import SwiftUI

struct AuthView: View {
    @Bindable var model: DemoFlowModel

    var body: some View {
        Form {
            Section("Demo Server") {
                TextField("Server URL", text: $model.session.serverURL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                TextField("User Email", text: $model.session.userEmail)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
            }

            if let errorMessage = model.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button(model.isBusy ? "Authenticating…" : "Authenticate") {
                    Task { await model.authenticate() }
                }
                .disabled(model.isBusy)
            }
        }
        .navigationTitle("Authenticate")
    }
}
