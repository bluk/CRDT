import XCTest

import CRDTCountersTests
import CRDTTests

var tests = [XCTestCaseEntry]()
tests += CRDTCountersTests.__allTests()
tests += CRDTTests.__allTests()

XCTMain(tests)
