//
//  PostHogApi.swift
//  PostHog
//
//  Created by Ben Heidemann on 18/12/2024.
//

import Foundation
import Nimble
import Quick
import XCTest

@testable import PostHog

class PostHogApiTest: QuickSpec {
    func getSut(
        host: String
    ) -> PostHogApi
    {
        let config = PostHogConfig(apiKey: "123", host: host)
        config.flushAt = 1
        config.disableReachabilityForTesting = true
        config.disableQueueTimerForTesting = true
        return PostHogApi(config)
    }
    
    override func spec() {
        var server: MockPostHogServer!
        
        func deleteDefaults() {
            let userDefaults = UserDefaults.standard
            userDefaults.removeObject(forKey: "PHGVersionKey")
            userDefaults.removeObject(forKey: "PHGBuildKeyV2")
            userDefaults.synchronize()
            
            deleteSafely(applicationSupportDirectoryURL())
        }
        
        beforeEach {
            deleteDefaults()
            server = MockPostHogServer()
            server.start()
        }
        afterEach {
            now = { Date() }
            server.stop()
            server = nil
            PostHogSessionManager.shared.endSession {}
        }

        context("batch") {
            func runURLCompositionTestCase(
                host: String,
                expectedURL: String
            ) {
                let sut = self.getSut(host: host)
                
                let event = PostHogEvent(event: "", distinctId: "");
                sut.batch(events: [event]) { result in
                    expect(result.error) == nil
                }

                let requests = getBatchedRequests(server);
                if (requests.count != 1) {
                    return XCTFail("Expected request count to be 1 but it was \(requests.count)")
                }

                let request = requests.first!;
                expect(request.url) == URL(string: expectedURL)
            }

            it("should request the correct URL") {
                runURLCompositionTestCase(
                    host: "https://localhost:9000",
                    expectedURL: "https://localhost:9000/batch"
                )
            }

            it("should request the correct URL when the host includes a trailing slash") {
                runURLCompositionTestCase(
                    host: "https://localhost:9000/",
                    expectedURL: "https://localhost:9000/batch"
                )
            }

            it("should request the correct URL when the host includes a path") {
                runURLCompositionTestCase(
                    host: "https://localhost:9000/a/b",
                    expectedURL: "https://localhost:9000/a/b/batch"
                )
            }
        }

        context("decide") {
            func runURLCompositionTestCase(
                host: String,
                expectedURL: String
            ) {
                let sut = self.getSut(host: host)

                sut.decide(
                    distinctId: "",
                    anonymousId: "",
                    groups: [:]
                ) { _, error in
                    expect(error) == nil
                }

                let requests = getDecideRequests(server);
                if (requests.count != 1) {
                    return XCTFail("Expected request count to be 1 but it was \(requests.count)")
                }

                let request = requests.first!;
                expect(request.url) == URL(string: expectedURL)
            }

            it("should request the correct URL") {
                runURLCompositionTestCase(
                    host: "https://localhost:9000",
                    expectedURL: "https://localhost:9000/decide?v=3"
                )
            }

            it("should request the correct URL when the host includes a trailing slash") {
                runURLCompositionTestCase(
                    host: "https://localhost:9000/",
                    expectedURL: "https://localhost:9000/decide?v=3"
                )
            }

            it("should request the correct URL when the host includes a path") {
                runURLCompositionTestCase(
                    host: "https://localhost:9000/a/b",
                    expectedURL: "https://localhost:9000/a/b/decide?v=3"
                )
            }
        }

        context("snapshot") {
            func runURLCompositionTestCase(
                host: String,
                expectedURL: String
            ) {
                let sut = self.getSut(host: host)

                let event = PostHogEvent(event: "", distinctId: "");
                sut.snapshot(events: [event]) { result in
                    expect(result.error) == nil
                }

                let requests = getSnapshotRequests(server);
                if (requests.count != 1) {
                    return XCTFail("Expected request count to be 1 but it was \(requests.count)")
                }

                let request = requests.first!;
                expect(request.url) == URL(string: expectedURL)
            }

            it("should request the correct URL") {
                runURLCompositionTestCase(
                    host: "https://localhost:9000",
                    expectedURL: "https://localhost:9000/s/"
                )
            }

            it("should request the correct URL when the host includes a trailing slash") {
                runURLCompositionTestCase(
                    host: "https://localhost:9000/",
                    expectedURL: "https://localhost:9000/s/"
                )
            }

            it("should request the correct URL when the host includes a path") {
                runURLCompositionTestCase(
                    host: "https://localhost:9000/a/b",
                    expectedURL: "https://localhost:9000/a/b/s/"
                )
            }
        }
    }
}
