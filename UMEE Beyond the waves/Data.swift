struct Prefs {
    struct Default {
        static let pngPath = "umee"
        static let delaySec = 60.0
        // not used, but for understanding because default value is false
        static let autostart = false
        static let ticker = "UMEE"
        static let precisionRound : Float = 4
    }
    struct Immutable {
        static let apiString = "https://api.coingecko.com/api/v3/simple/price"
        static let maximumInterval : Float = 3600
        static let minimumInterval : Float = 60
        static let menuBarFontSize = 13
        static let iconSize = 16
        static let coinData: [[String]] =
        [
            ["UMEE", "umee"],
            ["ATOM", "cosmos"],
            ["STRD", "stride"],
            ["OSMO", "osmo"],
            ["AXL", "axelar"]
        ]
    }
}
