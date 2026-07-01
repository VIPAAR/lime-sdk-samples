import SwiftUI
import HLSDKSwiftUI

struct JoinView: View {
    @Bindable var model: DemoFlowModel

    var body: some View {
        Group {
            if model.callPhase == .active {
                activeCallView
            } else {
                joinForm
            }
        }
        .navigationTitle("Join Call")
    }

    private var joinForm: some View {
        Form {
            Section("Session") {
                TextField("Session ID", text: $model.session.sessionID)
                TextField("PIN", text: $model.session.sessionPIN)
                TextField("GSS URL", text: $model.session.gssServerURL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                TextEditor(text: $model.session.sessionToken)
                    .frame(minHeight: 80)
            }

            Section("Local User") {
                TextField("Display Name", text: $model.session.displayName)
                TextField("Avatar URL", text: $model.session.avatarURL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                Toggle("Camera On", isOn: $model.session.cameraEnabled)
                Toggle("Microphone On", isOn: $model.session.microphoneEnabled)
            }

            Section("SDK") {
                SecureField("Help Lightning API Key", text: $model.session.apiKey)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            if case .ended(let message) = model.callPhase {
                Section("Call Status") {
                    Text(message)
                        .foregroundStyle(.red)
                }
            } else if !model.callStatusMessage.isEmpty {
                Section("Call Status") {
                    Text(model.callStatusMessage)
                }
            }

            if let errorMessage = model.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button(model.isBusy ? "Joining…" : "Join Call") {
                    Task { await model.joinCall() }
                }
                .disabled(model.isBusy || model.callPhase == .starting)
            }
        }
    }

    private var activeCallView: some View {
        ZStack {
            HLCallView()
                .preferredColorScheme(.dark)
#if os(iOS)
                .background(Color.black)
                .ignoresSafeArea()
#endif
#if os(visionOS)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
#endif
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("End Call") {
                    Task { await model.stopCall() }
                }
            }
        }
    }
}
