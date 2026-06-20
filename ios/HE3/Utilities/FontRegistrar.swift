import CoreText
import Foundation

/// Registers every bundled font at launch. The fonts are also declared in
/// UIAppFonts, but registering programmatically guarantees they load even if a
/// build path skips the plist step, so the brand serif and display faces render
/// reliably on device.
enum FontRegistrar {
    static func registerAll() {
        var urls: [URL] = []
        for ext in ["ttf", "otf"] {
            urls += Bundle.main.urls(forResourcesWithExtension: ext, subdirectory: nil) ?? []
            urls += Bundle.main.urls(forResourcesWithExtension: ext, subdirectory: "Fonts") ?? []
        }
        for url in Set(urls) {
            // Already registered via UIAppFonts is fine, the error is ignored.
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}
