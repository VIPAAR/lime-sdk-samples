import SwiftUI

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
    }
}
