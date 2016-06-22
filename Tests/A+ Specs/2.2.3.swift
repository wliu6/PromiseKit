import PromiseKit
import XCTest

// describe: 2.2.3: If `onRejected` is a function

class Test223: XCTestCase {

    // describe: 2.2.3.1: it must be called after `promise` is rejected,
    // with `promise`’s rejection reason as its first argument

    func test2231() {
        testRejected { promise, expectations, memo in
            promise.error { error in
                XCTAssertEqual(error, memo)
                expectations[0].fulfill()
            }
        }
    }
}

class Test2232: XCTestCase {

    // describe: 2.2.3.2: it must not be called before `promise` is rejected

    func test1() {

        // specify: rejected after a delay

        let expectation = self.expectation(withDescription: "rejected after a delay")
        let (promise, _, reject) = Promise<Int>.pendingPromise()
        var isRejected = false

        promise.error { _ in
            XCTAssertTrue(isRejected)
            expectation.fulfill()
        }
        later {
            reject(Error.dummy)
            isRejected = true
        }
        waitForExpectations(withTimeout: 1, handler: nil)
    }

    func test2() {

        // specify: never rejected

        class TestPromise : Promise<Void> {
            deinit {
                XCTAssertFalse(rejected)
            }
        }

        let expectation = self.expectation(withDescription: "")
        let (promise, _, _) = TestPromise.pendingPromise()

        promise.error { _ in
            XCTFail()
        }
        later {
            expectation.fulfill()
        }
        waitForExpectations(withTimeout: 1, handler: nil)
    }
}

class Test2233: XCTestCase {

    // describe 2.2.3.3: it must not be called more than once.

    func test1() {

        // specify: already-rejected

        let ex = expectation(withDescription: "")

        let p: Promise<Void> = Promise(error: Error.dummy)
        p.error { _ in
            ex.fulfill()
        }

        later(4, expectation(withDescription: "").fulfill)
        waitForExpectations(withTimeout: 1, handler: nil)
    }

    func test2() {

        // specify: trying to reject a pending promise more than once, immediately

        let ex = expectation(withDescription: "")
        let (promise, _, reject) = Promise<Void>.pendingPromise()

        promise.error { _ in ex.fulfill() }

        reject(Error.dummy)
        reject(Error.dummy)

        later(4, expectation(withDescription: "").fulfill)
        waitForExpectations(withTimeout: 1, handler: nil)
    }

    func test3() {

        // specify: trying to reject a pending promise more than once, delayed

        let ex = expectation(withDescription: "")
        let (promise, _, reject) = Promise<Void>.pendingPromise()

        promise.error { _ in ex.fulfill() }

        later {
            reject(Error.dummy)
            reject(Error.dummy)
        }

        later(4, expectation(withDescription: "").fulfill)
        waitForExpectations(withTimeout: 1, handler: nil)
    }

    func test4() {

        // specify: trying to reject a pending promise more than once, immediately then delayed

        let ex = expectation(withDescription: "")
        let (promise, _, reject) = Promise<Void>.pendingPromise()

        promise.error { _ in ex.fulfill() }

        reject(Error.dummy)
        later { reject(Error.dummy) }

        later(4, expectation(withDescription: "").fulfill)
        waitForExpectations(withTimeout: 1, handler: nil)
    }

    func test5() {

        // when multiple `then` calls are made, spaced apart in time

        let (promise, _, reject) = Promise<Void>.pendingPromise()

        let desc = "when multiple `then` calls are made, spaced apart in time"
        let e1 = expectation(withDescription: desc)
        let e2 = expectation(withDescription: desc)
        let e3 = expectation(withDescription: desc)

        promise.error { _ in e1.fulfill() }

        later(1) {
            promise.error { _ in e2.fulfill() }
        }
        later(2) {
            promise.error { _ in e3.fulfill() }
        }
        later(3) {
            reject(Error.dummy)
        }

        later(4, expectation(withDescription: "").fulfill)
        waitForExpectations(withTimeout: 1, handler: nil)
    }

    func test6() {

        // specify: when `then` is interleaved with rejection

        let (promise, _, reject) = Promise<Void>.pendingPromise()
        let e1 = expectation(withDescription: "")
        let e2 = expectation(withDescription: "")

        promise.error { _ in e1.fulfill() }
        reject(Error.dummy)
        promise.error { _ in e2.fulfill() }

        later(4, expectation(withDescription: "").fulfill)
        waitForExpectations(withTimeout: 1, handler: nil)
    }
}
