import SwiftUI
import HTMLKit

struct MyHTMLView: View {
    var body: AnyContent {
        Div {
            H1 { "Hello HTMLKit" }
            P { "This is an interactive preview." }
        }
    }
}

#Preview("Modo Estatico") {
    MyHTMLView()
}

#Preview("Modo Interactivo") {
    MyHTMLView()
}
