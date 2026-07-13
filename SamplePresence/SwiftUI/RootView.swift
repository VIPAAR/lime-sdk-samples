import SwiftUI
import HLSDKSwift

struct RootView: View {
    @State private var model = DemoFlowModel()

    var body: some View {
        NavigationStack(path: $model.path) {
            AuthView(model: model)
                .navigationDestination(for: DemoFlowRoute.self) { route in
                    switch route {
                    case .setup:
                        SetupView(model: model)
                    case .join:
                        JoinView(model: model)
                    }
                }
        }
        .navigationBarTitleDisplayMode(.inline)
#if os(iOS)
        .overlay(alignment: .topTrailing) {
            if model.pipEnabled, model.callPhase == .active {
                HLCallPiPView()
                    .padding()
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: model.pipEnabled)
#endif
    }
}
