//
//  TestPostHog.swift
//  PostHogTests
//
//  Created by Ben White on 22.03.23.
//

import Foundation
import PostHog
import XCTest

func waitBatchRequest(_ server: MockPostHogServer, timeout: TimeInterval = 15.0, failIfNotCompleted: Bool = true) {
    let result = XCTWaiter.wait(for: [server.batchExpectation!], timeout: timeout)

    if result != XCTWaiter.Result.completed, failIfNotCompleted {
        XCTFail("The expected requests never arrived")
    }
}

func getBatchedRequests(_ server: MockPostHogServer, timeout: TimeInterval = 15.0, failIfNotCompleted: Bool = true) -> [URLRequest] {
    waitBatchRequest(server, timeout: timeout, failIfNotCompleted: failIfNotCompleted)

    return server.batchRequests.reversed()
}

func getBatchedEvents(_ server: MockPostHogServer, timeout: TimeInterval = 15.0, failIfNotCompleted: Bool = true) -> [PostHogEvent] {
    let requests = getBatchedRequests(server, timeout: timeout, failIfNotCompleted: failIfNotCompleted)
    var events: [PostHogEvent] = []
    for request in requests {
        let items = server.parsePostHogEvents(request)
        events.append(contentsOf: items)
    }

    return events
}

func waitDecideRequest(_ server: MockPostHogServer) {
    let result = XCTWaiter.wait(for: [server.decideExpectation!], timeout: 15)

    if result != XCTWaiter.Result.completed {
        XCTFail("The expected requests never arrived")
    }
}

func getDecideRequests(_ server: MockPostHogServer) -> [URLRequest] {
    waitDecideRequest(server)

    return server.decideRequests.reversed()
}

func getDecideRequestsParsed(_ server: MockPostHogServer) -> [[String: Any]] {
    let requests = getDecideRequests(server)
    var requests_parsed: [[String: Any]] = []
    for request in requests {
        let item = server.parseRequest(request, gzip: false)
        requests_parsed.append(item!)
    }

    return requests_parsed
}

func waitSnapshotRequest(_ server: MockPostHogServer, timeout: TimeInterval = 15.0, failIfNotCompleted: Bool = true) {
    let result = XCTWaiter.wait(for: [server.snapshotExpectation!], timeout: timeout)

    if result != XCTWaiter.Result.completed, failIfNotCompleted {
        XCTFail("The expected requests never arrived")
    }
}

func getSnapshotRequests(_ server: MockPostHogServer, timeout: TimeInterval = 15.0, failIfNotCompleted: Bool = true) -> [URLRequest] {
    waitSnapshotRequest(server, timeout: timeout, failIfNotCompleted: failIfNotCompleted)

    return server.snapshotRequests.reversed()
}

