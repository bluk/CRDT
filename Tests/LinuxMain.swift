import XCTest

import CRDTCountersTests
import CRDTRegistersTests
import CRDTSetsTests
import CRDTTests

var tests = [XCTestCaseEntry]()
tests += CRDTCountersTests.__allTests()
tests += CRDTRegistersTests.__allTests()
tests += CRDTSetsTests.__allTests()
tests += CRDTTests.__allTests()

XCTMain(tests)
