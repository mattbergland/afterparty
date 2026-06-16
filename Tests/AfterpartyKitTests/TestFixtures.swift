import Foundation
@testable import AfterpartyKit

enum Fixtures {
    /// The canonical example from the Afterparty spec.
    static let sarahNote = "Met Sarah at the AI dinner. She runs developer marketing at Datadog. We talked about customer hackathons and SF venues."

    static var sarahRequest: FollowUpRequest {
        FollowUpRequest(noteText: sarahNote, tone: .warm, senderName: "Matt")
    }
}
