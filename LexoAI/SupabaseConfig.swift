import Foundation

enum SupabaseConfig {
    static let projectURL = URL(string: "https://odiafnwopeibwfypkgpb.supabase.co")!
    // Publishable key: intended for public client applications.
    // Never put a service_role or secret key in an iOS app.
    static let publishableKey = "sb_publishable_8LXEWmdvBsdxM5ZkJP8xyg_1ZVZGFOi"
    static let signupFunctionURL = projectURL.appending(path: "functions/v1/lexo-android-signup")
    static let streamFunctionURL = projectURL.appending(path: "functions/v1/lexo-android-stream")
}