import SwiftUI
import TipKit

struct SummaryTip: Tip {
    var title: Text {
        Text("AI Summary")
    }
    
    var message: Text? {
        Text("Tap here to generate a concise summary of today's top news using AI.")
    }
    
    var image: Image? {
        Image(systemName: "wand.and.stars")
    }
}
