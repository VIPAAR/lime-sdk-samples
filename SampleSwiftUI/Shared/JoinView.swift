import SwiftUI
import HLSDKSwift

struct JoinView: View {
    @Bindable var model: DemoFlowModel

    var body: some View {
        joinForm
            .navigationTitle("Join Call")
            .fullScreenCover(isPresented: callPresentationBinding) {
                callPresentation
            }
    }

    private var callPresentationBinding: Binding<Bool> {
        Binding(
            get: {
                switch model.callPhase {
                case .starting, .active:
                    return true
                default:
                    return false
                }
            },
            set: { isPresented in
                guard !isPresented else { return }
                switch model.callPhase {
                case .starting, .active:
                    Task { await model.stopCall() }
                default:
                    break
                }
            }
        )
    }

    private var callPresentation: some View {
        Group {
            if model.callPhase == .active {
                activeCallView
            } else {
                ZStack {
                    Color.black.ignoresSafeArea()
                    ProgressView("Joining…")
                        .tint(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var joinForm: some View {
        Form {
            Section("Session") {
                LabeledContent("Session ID: ") {
                    TextField("", text: $model.session.sessionID, prompt: Text("Required"))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                LabeledContent("PIN: ") {
                    TextField("", text: $model.session.sessionPIN, prompt: Text("Required"))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                LabeledContent("GSS URL: ") {
                    TextField("", text: $model.session.gssServerURL, prompt: Text("gss+ssl://…"))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                LabeledContent {
                    TextEditor(text: $model.session.sessionToken)
                        .frame(minHeight: 80)
                } label: {
                    Text("Session Token: ")
                }
            }

            Section("Local User") {
                LabeledContent("Display Name: ") {
                    TextField("", text: $model.session.displayName, prompt: Text("Required"))
                }
                LabeledContent("Avatar URL: ") {
                    TextField("", text: $model.session.avatarURL, prompt: Text("https://…"))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                Toggle("Camera On", isOn: $model.session.cameraEnabled)
                Toggle("Microphone On", isOn: $model.session.microphoneEnabled)
            }

            Section("API Key") {
                LabeledContent("Help Lightning API Key: ") {
                    TextField("", text: $model.session.apiKey, prompt: Text("Required"))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
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
        HLCallView()
#if os(iOS)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .ignoresSafeArea()
#endif
#if os(visionOS)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
#endif
    }
}
