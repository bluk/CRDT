import XCTest

import CRDTTests

var tests = [XCTestCaseEntry]()
tests += CRDTTests.__allTests()

XCTMain(tests)
