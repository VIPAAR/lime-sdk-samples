import SwiftUI

struct AuthView: View {
    @Bindable var model: DemoFlowModel

    var body: some View {
        Form {
            Section("Demo Server") {
                LabeledContent("Server URL: ") {
                    TextField("", text: $model.session.serverURL, prompt: Text("http://127.0.0.1:8777"))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                LabeledContent("User Email: ") {
                    TextField("", text: $model.session.userEmail, prompt: Text("user@example.com"))
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                }
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
