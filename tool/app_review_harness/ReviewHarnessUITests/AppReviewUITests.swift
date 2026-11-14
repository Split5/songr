import AVFoundation
import Photos
import XCTest

final class AppReviewUITests: XCTestCase {
    private let app = XCUIApplication(
        bundleIdentifier: "se.simonbystrom.navimusic"
    )

    override func setUpWithError() throws {
        continueAfterFailure = false
        addUIInterruptionMonitor(withDescription: "iOS permission") { alert in
            for label in ["Allow", "OK", "Tillåt"] {
                let button = alert.buttons[label]
                if button.exists {
                    button.tap()
                    return true
                }
            }
            return false
        }
    }

    func testDemoWalkthrough() throws {
        app.launchArguments += [
            "-AppleLanguages", "(en)",
            "-AppleLocale", "en_US",
        ]
        let recorder = openControlCenter()
        tapScreenRecording(in: recorder)
        app.launch()
        ensureConfigured()
        sleep(4)

        tap(app.buttons["Settings"].firstMatch, label: "Settings")
        sleep(2)
        tapAny(containing: "Server settings")
        sleep(3)

        let fields = app.textFields
        XCTAssertTrue(fields.element(boundBy: 0).waitForExistence(timeout: 20))
        XCTAssertEqual(
            fields.element(boundBy: 0).value as? String,
            "https://musik.simonbystrom.se"
        )
        XCTAssertEqual(fields.element(boundBy: 1).value as? String, "demo")

        tap(app.buttons["Connect and save"], label: "Connect and save")
        XCTAssertTrue(
            app.staticTexts["Settings"].waitForExistence(timeout: 30),
            app.debugDescription
        )
        sleep(3)
        tapBackButton()
        XCTAssertTrue(
            app.staticTexts["Quick Picks"].waitForExistence(timeout: 30)
        )
        sleep(3)

        tapAny(containing: "Search")
        let search = app.textFields.firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: 20))
        search.tap()
        search.typeText("Adele")
        sleep(5)
        let done = app.buttons["Done"]
        if done.waitForExistence(timeout: 3) {
            done.tap()
            sleep(1)
        }

        tapAny(containing: "Library")
        sleep(2)
        tapAny(containing: "Albums")
        XCTAssertTrue(
            any(containing: "Back to Black").waitForExistence(timeout: 30),
            app.debugDescription
        )
        sleep(3)
        tapAny(containing: "Back to Black")
        XCTAssertTrue(
            any(containing: "Rehab").waitForExistence(timeout: 30),
            app.debugDescription
        )
        sleep(2)
        tapAny(containing: "Rehab")
        sleep(5)

        if !any(containing: "Queue").exists {
            let miniPlayer = app.buttons.matching(
                NSPredicate(format: "label CONTAINS[c] %@", "Amy Winehouse")
            ).firstMatch
            XCTAssertTrue(
                miniPlayer.waitForExistence(timeout: 20),
                app.debugDescription
            )
            miniPlayer.tap()
        }
        XCTAssertTrue(any(containing: "Queue").waitForExistence(timeout: 20))
        sleep(5)
        tapAny(containing: "Queue")
        sleep(4)
        _ = openControlCenter()
        tapScreenRecording(in: recorder, stopping: true)
        sleep(5)
        attachLatestVideoFromPhotos()
    }

    func testControlCenterLabels() throws {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        springboard.activate()
        let start = springboard.coordinate(
            withNormalizedOffset: CGVector(dx: 0.95, dy: 0.01)
        )
        let end = springboard.coordinate(
            withNormalizedOffset: CGVector(dx: 0.95, dy: 0.72)
        )
        start.press(forDuration: 0.1, thenDragTo: end)
        sleep(3)
        print(springboard.debugDescription)
    }

    func testScreenRecordingExport() throws {
        let springboard = openControlCenter()
        tapScreenRecording(in: springboard)
        sleep(5)
        _ = openControlCenter()
        tapScreenRecording(in: springboard, stopping: true)
        sleep(5)
        attachLatestVideoFromPhotos()
    }

    func testRegressionFixVerification() throws {
        app.launchArguments += [
            "-AppleLanguages", "(en)",
            "-AppleLocale", "en_US",
        ]
        app.launch()
        ensureConfigured()
        XCTAssertTrue(
            app.staticTexts["Quick Picks"].waitForExistence(timeout: 45),
            app.debugDescription
        )

        let home = XCTAttachment(screenshot: app.screenshot())
        home.name = "Home after fixes"
        home.lifetime = .keepAlways
        add(home)

        tap(app.buttons["Library"].firstMatch, label: "Library tab")
        sleep(2)
        tapAny(containing: "Playlists")
        XCTAssertTrue(
            any(containing: "Best singing").waitForExistence(timeout: 20),
            app.debugDescription
        )

        let playlist = any(containing: "Best singing")
        playlist.swipeRight()
        XCTAssertTrue(
            app.alerts.buttons["Delete"].waitForExistence(timeout: 10),
            app.debugDescription
        )

        let swipe = XCTAttachment(screenshot: app.screenshot())
        swipe.name = "Playlist swipe delete confirmation"
        swipe.lifetime = .keepAlways
        add(swipe)

        tap(app.alerts.buttons["Cancel"], label: "Cancel playlist deletion")
    }

    func testCachedHomeSurvivesRelaunch() throws {
        app.launchArguments += [
            "-AppleLanguages", "(en)",
            "-AppleLocale", "en_US",
        ]
        app.launch()
        ensureConfigured()
        XCTAssertTrue(
            app.staticTexts["Quick Picks"].waitForExistence(timeout: 45),
            app.debugDescription
        )

        app.terminate()
        app.launch()

        XCTAssertTrue(
            app.staticTexts["Quick Picks"].waitForExistence(timeout: 30),
            app.debugDescription
        )
        XCTAssertFalse(app.staticTexts["Nothing to show yet."].exists)

        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Cached home after relaunch"
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }

    func testHeaderBlurWhenContentScrollsUnder() throws {
        app.launchArguments += [
            "-AppleLanguages", "(en)",
            "-AppleLocale", "en_US",
        ]
        app.launch()
        XCTAssertTrue(
            app.staticTexts["Quick Picks"].waitForExistence(timeout: 45),
            app.debugDescription
        )

        app.swipeUp()
        sleep(2)

        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Blurred translucent app header"
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }

    func testChromeTransparencySettings() throws {
        app.launchArguments += [
            "-AppleLanguages", "(en)",
            "-AppleLocale", "en_US",
        ]
        app.launch()
        XCTAssertTrue(
            app.staticTexts["Quick Picks"].waitForExistence(timeout: 45),
            app.debugDescription
        )

        let settings = app.buttons["Settings"].firstMatch
        XCTAssertTrue(settings.waitForExistence(timeout: 20), "Settings")
        settings.coordinate(
            withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)
        ).tap()
        tapAny(containing: "Appearance")
        sleep(2)

        let settingsScreenshot = XCTAttachment(screenshot: app.screenshot())
        settingsScreenshot.name = "Transparency settings screen"
        settingsScreenshot.lifetime = .keepAlways
        add(settingsScreenshot)

        app.coordinate(
            withNormalizedOffset: CGVector(dx: 0.98, dy: 0.315)
        ).tap()
        app.coordinate(
            withNormalizedOffset: CGVector(dx: 0.02, dy: 0.461)
        ).tap()
        sleep(1)

        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Top transparency and blur settings"
        screenshot.lifetime = .keepAlways
        add(screenshot)

        tapBackButton()
        tapBackButton()
        app.swipeUp()
        sleep(2)

        let homeScreenshot = XCTAttachment(screenshot: app.screenshot())
        homeScreenshot.name = "Clear transparent header"
        homeScreenshot.lifetime = .keepAlways
        add(homeScreenshot)
    }

    func testMarketingScreenshotsSwedish() throws {
        try captureMarketingScreenshots(
            language: "sv",
            locale: "sv_SE",
            queueLabel: "Kö"
        )
    }

    func testMarketingScreenshotsEnglish() throws {
        try captureMarketingScreenshots(
            language: "en",
            locale: "en_US",
            queueLabel: "Queue"
        )
    }

    func testAppReviewRecordingFlow() throws {
        app.terminate()
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        springboard.activate()
        sleep(2)

        let appIcon = springboard.icons.matching(
            NSPredicate(format: "label CONTAINS[c] %@", "ngr")
        ).firstMatch
        XCTAssertTrue(appIcon.waitForExistence(timeout: 15), "Söngr app icon")
        appIcon.tap()

        XCTAssertTrue(
            app.buttons["Inställningar"].firstMatch.waitForExistence(timeout: 45),
            app.debugDescription
        )
        sleep(2)
        tap(app.buttons["Inställningar"].firstMatch, label: "Inställningar")
        sleep(2)
        tapAny(containing: "Serverinställningar")
        sleep(3)
        tapAny(containing: "Anslut")
        XCTAssertTrue(
            firstButton(containing: "Hem").waitForExistence(timeout: 30),
            app.debugDescription
        )
        sleep(2)

        let search = tabButton("Sök")
        XCTAssertTrue(search.waitForExistence(timeout: 15))
        search.tap()
        let searchField = app.textFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 15))
        searchField.tap()
        searchField.typeText("Rehab")
        let done = app.buttons["Klar"]
        if done.waitForExistence(timeout: 3) {
            done.tap()
        }
        let rehab = firstButton(containing: "Rehab")
        XCTAssertTrue(rehab.waitForExistence(timeout: 20))
        rehab.tap()
        sleep(4)

        app.coordinate(
            withNormalizedOffset: CGVector(dx: 0.2, dy: 0.9)
        ).tap()
        let queue = firstButton(containing: "Kö")
        XCTAssertTrue(queue.waitForExistence(timeout: 20))
        sleep(3)
        queue.tap()
        sleep(5)
    }

    func testHomeLogoHeader() throws {
        app.launchArguments += [
            "-AppleLanguages", "(en)",
            "-AppleLocale", "en_US",
        ]
        app.launch()
        XCTAssertTrue(
            app.staticTexts["Quick Picks"].waitForExistence(timeout: 45),
            app.debugDescription
        )

        tap(app.buttons["Settings"].firstMatch, label: "Settings")
        sleep(2)
        tapAny(containing: "Customize Home")
        let logoSwitch = app.switches["Show logo"]
        XCTAssertTrue(logoSwitch.waitForExistence(timeout: 15))
        if !logoSwitch.isSelected {
            logoSwitch.tap()
        }
        tapBackButton()
        sleep(2)

        XCTAssertTrue(
            app.images["Soengr"].waitForExistence(timeout: 15),
            app.debugDescription
        )
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Transparent logo header"
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }

    private func tap(_ element: XCUIElement, label: String) {
        XCTAssertTrue(element.waitForExistence(timeout: 20), label)
        element.tap()
    }

    private func any(containing label: String) -> XCUIElement {
        app.descendants(matching: .any).matching(
            NSPredicate(format: "label CONTAINS[c] %@", label)
        ).firstMatch
    }

    private func tapAny(containing label: String) {
        tap(any(containing: label), label: label)
    }

    private func captureMarketingScreenshots(
        language: String,
        locale: String,
        queueLabel: String
    ) throws {
        app.launchArguments += [
            "-AppleLanguages", "(\(language))",
            "-AppleLocale", locale,
        ]
        app.launch()
        ensureConfigured()
        XCTAssertTrue(
            app.buttons[language == "sv" ? "Inställningar" : "Settings"]
                .firstMatch
                .waitForExistence(timeout: 45),
            app.debugDescription
        )
        sleep(2)
        attachScreenshot("marketing-\(language)-01-home")

        let search = tabButton(language == "sv" ? "Sök" : "Search")
        XCTAssertTrue(search.waitForExistence(timeout: 15))
        search.tap()
        let searchField = app.textFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 15))
        searchField.tap()
        searchField.typeText("Adele")
        let done = app.buttons[language == "sv" ? "Klar" : "Done"]
        if done.waitForExistence(timeout: 3) {
            done.tap()
        }
        sleep(3)
        attachScreenshot("marketing-\(language)-02-search")

        let library = tabButton(
            language == "sv" ? "Bibliotek" : "Library"
        )
        XCTAssertTrue(library.waitForExistence(timeout: 15))
        library.tap()
        sleep(3)
        attachScreenshot("marketing-\(language)-03-library")

        tapAny(containing: language == "sv" ? "Album" : "Albums")
        XCTAssertTrue(
            any(containing: "Back to Black").waitForExistence(timeout: 30),
            app.debugDescription
        )
        sleep(2)
        attachScreenshot("marketing-\(language)-04-albums")

        XCTAssertTrue(search.waitForExistence(timeout: 15))
        search.tap()
        replaceText(in: searchField, with: "Rehab")
        let doneSearching = app.buttons[language == "sv" ? "Klar" : "Done"]
        if doneSearching.waitForExistence(timeout: 3) {
            doneSearching.tap()
        }
        sleep(1)
        let rehab = firstButton(containing: "Rehab")
        XCTAssertTrue(
            rehab.waitForExistence(timeout: 20),
            app.debugDescription
        )
        rehab.press(forDuration: 0.9)
        sleep(2)
        attachScreenshot("marketing-\(language)-05-song-actions")
        app.coordinate(
            withNormalizedOffset: CGVector(dx: 0.9, dy: 0.2)
        ).tap()
        sleep(2)
        if UIDevice.current.userInterfaceIdiom == .pad {
            return
        }

        let playingRow = firstButton(containing: "Rehab")
        XCTAssertTrue(playingRow.waitForExistence(timeout: 15))
        playingRow.tap()
        sleep(3)
        app.coordinate(
            withNormalizedOffset: CGVector(dx: 0.2, dy: 0.9)
        ).tap()
        let queueButton = firstButton(containing: queueLabel)
        XCTAssertTrue(queueButton.waitForExistence(timeout: 20))
        sleep(3)
        attachScreenshot("marketing-\(language)-06-player")

        XCTAssertTrue(queueButton.waitForExistence(timeout: 15))
        queueButton.tap()
        sleep(3)
        attachScreenshot("marketing-\(language)-07-queue")
        app.swipeDown()
        sleep(2)

        let lyricsButton = firstButton(
            containing: language == "sv" ? "Låttext" : "Lyrics"
        )
        XCTAssertTrue(lyricsButton.waitForExistence(timeout: 15))
        lyricsButton.tap()
        sleep(4)
        attachScreenshot("marketing-\(language)-08-lyrics")
    }

    private func tabButton(_ label: String) -> XCUIElement {
        app.buttons.matching(
            NSPredicate(format: "label BEGINSWITH[c] %@", label)
        ).firstMatch
    }

    private func firstButton(containing label: String) -> XCUIElement {
        app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] %@", label)
        ).firstMatch
    }

    private func attachScreenshot(_ name: String) {
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = name
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }

    private func ensureConfigured() {
        if app.staticTexts["Quick Picks"].waitForExistence(timeout: 12) {
            return
        }

        let connect = app.buttons["Connect and save"]
        XCTAssertTrue(connect.waitForExistence(timeout: 20), app.debugDescription)
        let fields = app.textFields
        XCTAssertTrue(fields.element(boundBy: 0).waitForExistence(timeout: 10))
        replaceText(
            in: fields.element(boundBy: 0),
            with: "https://musik.simonbystrom.se"
        )
        replaceText(in: fields.element(boundBy: 1), with: "demo")
        let securePassword = app.secureTextFields.firstMatch
        let password = securePassword.waitForExistence(timeout: 2)
            ? securePassword
            : fields.element(boundBy: 2)
        XCTAssertTrue(password.exists)
        password.tap()
        sleep(1)
        let keyboard = app.keyboards.firstMatch
        XCTAssertTrue(keyboard.waitForExistence(timeout: 10))
        for key in ["d", "e", "m", "o"] {
            let keyboardKey = keyboard.keys[key]
            XCTAssertTrue(keyboardKey.waitForExistence(timeout: 5), key)
            keyboardKey.tap()
        }
        tap(connect, label: "Connect and save")
        XCTAssertTrue(
            app.staticTexts["Quick Picks"].waitForExistence(timeout: 45),
            app.debugDescription
        )
    }

    private func replaceText(in field: XCUIElement, with value: String) {
        field.coordinate(
            withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)
        ).tap()
        sleep(1)
        for label in ["Continue", "Fortsätt"] {
            let button = app.buttons[label]
            if button.waitForExistence(timeout: 1) {
                button.tap()
                sleep(1)
                field.coordinate(
                    withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)
                ).tap()
                break
            }
        }
        if let current = field.value as? String, !current.isEmpty {
            field.typeText(
                String(
                    repeating: XCUIKeyboardKey.delete.rawValue,
                    count: current.count
                )
            )
        }
        field.typeText(value)
    }

    private func tapBackButton() {
        let navigationBack = app.navigationBars.buttons.firstMatch
        if navigationBack.exists {
            navigationBack.tap()
            return
        }
        let back = app.buttons["Back"].firstMatch
        XCTAssertTrue(back.waitForExistence(timeout: 10))
        back.tap()
    }

    private func openControlCenter() -> XCUIApplication {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        springboard.activate()
        let start = springboard.coordinate(
            withNormalizedOffset: CGVector(dx: 0.95, dy: 0.01)
        )
        let end = springboard.coordinate(
            withNormalizedOffset: CGVector(dx: 0.95, dy: 0.72)
        )
        start.press(forDuration: 0.1, thenDragTo: end)
        sleep(2)
        return springboard
    }

    private func closeControlCenter(_ springboard: XCUIApplication) {
        let start = springboard.coordinate(
            withNormalizedOffset: CGVector(dx: 0.5, dy: 0.92)
        )
        let end = springboard.coordinate(
            withNormalizedOffset: CGVector(dx: 0.5, dy: 0.05)
        )
        start.press(forDuration: 0.1, thenDragTo: end)
        sleep(1)
    }

    private func tapScreenRecording(
        in springboard: XCUIApplication,
        stopping: Bool = false
    ) {
        let recording = springboard.buttons.matching(
            NSPredicate(
                format: "label == %@ OR label == %@",
                "Skärminspelning",
                "Screen Recording"
            )
        ).firstMatch

        for _ in 0..<3 where !recording.isHittable {
            let pageStart = springboard.coordinate(
                withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2)
            )
            let pageEnd = springboard.coordinate(
                withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9)
            )
            pageStart.press(forDuration: 0.05, thenDragTo: pageEnd)
            sleep(1)
        }
        XCTAssertTrue(recording.waitForExistence(timeout: 10), springboard.debugDescription)
        recording.tap()
        sleep(2)

        if stopping {
            let stop = springboard.alerts.buttons.matching(
                NSPredicate(format: "label == %@ OR label == %@", "Stoppa", "Stop")
            ).firstMatch
            if stop.waitForExistence(timeout: 3) {
                stop.tap()
            }
        } else {
            closeControlCenter(springboard)
        }
    }

    private func attachLatestVideoFromPhotos() {
        let authorization = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if authorization == .notDetermined {
            let request = DispatchSemaphore(value: 0)
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { _ in
                request.signal()
            }
            sleep(2)
            let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
            if springboard.alerts.firstMatch.exists {
                for label in [
                    "Tillåt full åtkomst",
                    "Allow Full Access",
                    "Tillåt",
                    "Allow",
                ] {
                    let button = springboard.alerts.buttons[label]
                    if button.exists {
                        button.tap()
                        break
                    }
                }
            }
            _ = request.wait(timeout: .now() + 15)
        }
        XCTAssertTrue(
            [.authorized, .limited].contains(
                PHPhotoLibrary.authorizationStatus(for: .readWrite)
            )
        )

        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false),
        ]
        guard let asset = PHAsset.fetchAssets(with: .video, options: options).firstObject
        else {
            XCTFail("No video found in Photos")
            return
        }

        let request = DispatchSemaphore(value: 0)
        var requestedAsset: AVAsset?
        PHImageManager.default().requestAVAsset(
            forVideo: asset,
            options: nil
        ) { avAsset, _, _ in
            requestedAsset = avAsset
            request.signal()
        }
        XCTAssertEqual(request.wait(timeout: .now() + 30), .success)
        guard let avAsset = requestedAsset else {
            XCTFail("Could not load the screen recording")
            return
        }

        let output = FileManager.default.temporaryDirectory
            .appendingPathComponent("app-review-recording.mp4")
        try? FileManager.default.removeItem(at: output)
        guard let exporter = AVAssetExportSession(
            asset: avAsset,
            presetName: AVAssetExportPresetHighestQuality
        ) else {
            XCTFail("Could not create video exporter")
            return
        }
        exporter.outputURL = output
        exporter.outputFileType = .mp4

        let exportFinished = DispatchSemaphore(value: 0)
        exporter.exportAsynchronously {
            exportFinished.signal()
        }
        XCTAssertEqual(exportFinished.wait(timeout: .now() + 60), .success)
        XCTAssertEqual(exporter.status, .completed)

        let attachment = XCTAttachment(contentsOfFile: output)
        attachment.name = "Söngr App Review screen recording"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
