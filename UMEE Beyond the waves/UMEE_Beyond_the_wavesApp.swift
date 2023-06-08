//
//  UMEE_Beyond_the_wavesApp.swift
//  UMEE Beyond the waves
//
//  Created by quantum on 08.06.2023.
//

import LaunchAtLogin
import SwiftUI
import AppKit

// global objects
var statusItem: NSStatusItem?
var icon : NSImage?
var timer : Timer?

// API answer
struct APIAnswer {
    var data: Data?
    var response: URLResponse?
    var error : Error?
}

// preferences
struct Preferences {
    var delaySec : Double
    var pngPath : String
    var ticker : String
    var autostart : Bool
    var precisionRound: Float
    init() {
        let delaySec = defaults.double(forKey: "delaySec")
        if (delaySec == 0) {self.delaySec = Prefs.Default.delaySec}
        else {self.delaySec = delaySec}
        self.pngPath = defaults.string(forKey: "pngPath") ?? Prefs.Default.pngPath
        self.ticker = defaults.string(forKey: "ticker") ?? Prefs.Default.ticker
        self.autostart = defaults.bool(forKey: "autostart")
        self.precisionRound = Prefs.Default.precisionRound
    }
}

var prefs = Preferences()
var defaults = UserDefaults.standard

/// Fuction for getting information through CoinGecko API
func get_price() {
    var ans = APIAnswer()
    let url = URL(string: Prefs.Immutable.apiString + "?ids=" + prefs.pngPath + "&vs_currencies=usd")!
    let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
        guard let _ = data else {return}
        ans.data = data
        ans.response = response
        ans.error = error
        DispatchQueue.main.async {display_data(ans: ans)}
    }
    task.resume()
}

/// Function for saving preferences from Defaults
func save_prefs(delaySec : Double, pngPath : String, ticker : String, autostart: Bool) {
    defaults.set(delaySec, forKey: "delaySec")
    defaults.set(pngPath, forKey: "pngPath")
    defaults.set(ticker, forKey: "ticker")
    defaults.set(autostart, forKey: "autostart")
    prefs.delaySec = delaySec
    prefs.pngPath = pngPath
    prefs.ticker = ticker
    prefs.autostart = autostart
    timer!.invalidate()
    infinity_timer(time: delaySec)
    LaunchAtLogin.isEnabled = autostart
}

/// Function for checking fields from "Preferences"
func check_data(delaySec : String) -> Bool {
    let delay = Float(delaySec)
    if (delay == nil || delay! < Prefs.Immutable.minimumInterval || delay! > Prefs.Immutable.maximumInterval) {return true}

    return false
}

/// Function for displaying data on menu bar
func display_data(ans : APIAnswer) {
    let statusCode = (ans.response as? HTTPURLResponse)?.statusCode ?? -1
    let data = ans.data
    if (statusCode != 200 || data == nil) {
        icon = NSImage(named: prefs.pngPath)
        icon?.size = NSSize(width: Prefs.Immutable.iconSize, height: Prefs.Immutable.iconSize)
        statusItem?.button?.imagePosition = NSControl.ImagePosition.imageLeft
        statusItem?.button?.image = icon
        statusItem?.button?.title = " API error"
        return
    }
    else {
        if let json = try? JSONSerialization
            .jsonObject(with: ans.data!,
                        options: .allowFragments) as? [String: Any] {
            let data = json[prefs.pngPath] as? Dictionary<String, AnyObject>
            let price = (data?.first!.value)!.floatValue!
            let _price_ = roundf(price*pow(10, Prefs.Default.precisionRound))/pow(10, Prefs.Default.precisionRound)
            icon = NSImage(named: prefs.pngPath)
            icon?.size = NSSize(width: Prefs.Immutable.iconSize,
                                height: Prefs.Immutable.iconSize)
            statusItem?.button?.imagePosition = NSControl.ImagePosition.imageLeft
            statusItem?.button?.image = icon
            statusItem?.button?.title = " " + prefs.ticker + " $" + String(_price_)
        }
        else {
            icon = NSImage(named: prefs.pngPath)
            icon?.size = NSSize(width: Prefs.Immutable.iconSize, height: Prefs.Immutable.iconSize)
            statusItem?.button?.imagePosition = NSControl.ImagePosition.imageLeft
            statusItem?.button?.image = icon
            statusItem?.button?.title = " Parse error"
        }
    }
}

/// Infinity loop function
func infinity_timer(time: Double) {
    get_price()
    timer = Timer.scheduledTimer(withTimeInterval: time, repeats: true) { (t) in
        get_price()
    }
}

/// Class AppDelegate
class AppDelegate: NSObject, NSApplicationDelegate {
    var popover: NSPopover!
    /// Function when app did launching
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.font = NSFont.systemFont(ofSize: CGFloat(Prefs.Immutable.menuBarFontSize))
        statusItem?.button?.title = "Loading price"
        // Create the popover and sets ContentView as the rootView
        let contentView = ContentView()
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 380, height: 380)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
        self.popover = popover
        statusItem?.button?.action = #selector(togglePopover(_:))
    }
    
    /// Function for popover
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = statusItem?.button {
            if self.popover.isShown {
                self.popover.performClose(sender)
            } else {
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }
}

/// Main function
@main
struct UMEE_Beyond_the_wavesApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Settings {
            AnyView(erasing: ContentView())
        }
    }
    let result: () = infinity_timer(time: prefs.delaySec)
}
