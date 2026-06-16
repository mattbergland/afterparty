import SwiftUI

@main
struct AfterpartyApp: App {
    @StateObject private var viewModel = FollowUpViewModel.live()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(viewModel)
                .preferredColorScheme(.dark)
        }
    }
}
