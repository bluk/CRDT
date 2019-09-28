#if !canImport(ObjectiveC)
import XCTest

extension LSEQTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__LSEQTests = [
        ("testApplySameInsertOperation", testApplySameInsertOperation),
        ("testApplySameRemoveOperation", testApplySameRemoveOperation),
        ("testInit", testInit),
        ("testInsertAndRemove", testInsertAndRemove),
        ("testInsertAndRemoveElementCount", testInsertAndRemoveElementCount),
        ("testInsertElement", testInsertElement),
        ("testInsertElementCountAtBeginning", testInsertElementCountAtBeginning),
        ("testInsertElementCountAtEnd", testInsertElementCountAtEnd),
        ("testInsertElementCountInRandomIndex", testInsertElementCountInRandomIndex),
        ("testInsertionPattern1", testInsertionPattern1),
        ("testInsertionPattern2", testInsertionPattern2),
        ("testMakeDifferenceOperations1", testMakeDifferenceOperations1),
        ("testMakeDifferenceOperations2", testMakeDifferenceOperations2),
        ("testMakeDifferenceOperations3", testMakeDifferenceOperations3),
        ("testMergeBehavior1", testMergeBehavior1),
        ("testMergeBehavior2", testMergeBehavior2),
    ]
}

extension PositionAllocatorTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__PositionAllocatorTests = [
        ("testPositionAllocate_differenceAtMax_level0", testPositionAllocate_differenceAtMax_level0),
        ("testPositionAllocate_differenceAtMax_level1", testPositionAllocate_differenceAtMax_level1),
        ("testPositionAllocate_differenceAtMax_level2", testPositionAllocate_differenceAtMax_level2),
        ("testPositionAllocate_differenceAtMin_level0", testPositionAllocate_differenceAtMin_level0),
        ("testPositionAllocate_differenceAtMin_level1", testPositionAllocate_differenceAtMin_level1),
        ("testPositionAllocate_differenceAtMin_level2", testPositionAllocate_differenceAtMin_level2),
        ("testPositionAllocate_differenceGreaterThanBoundary_level0", testPositionAllocate_differenceGreaterThanBoundary_level0),
        ("testPositionAllocate_differenceGreaterThanBoundary_level1", testPositionAllocate_differenceGreaterThanBoundary_level1),
        ("testPositionAllocate_differenceGreaterThanBoundary_level2", testPositionAllocate_differenceGreaterThanBoundary_level2),
        ("testPositionAllocate_differenceLessThanBoundary_level0", testPositionAllocate_differenceLessThanBoundary_level0),
        ("testPositionAllocate_differenceLessThanBoundary_level1", testPositionAllocate_differenceLessThanBoundary_level1),
        ("testPositionAllocate_differenceLessThanBoundary_level2", testPositionAllocate_differenceLessThanBoundary_level2),
        ("testPositionAllocate_differenceOnly1_level0", testPositionAllocate_differenceOnly1_level0),
        ("testPositionAllocate_differenceOnly1_level1", testPositionAllocate_differenceOnly1_level1),
        ("testPositionAllocate_differenceOnly1_level2", testPositionAllocate_differenceOnly1_level2),
        ("testPositionAllocate_PLessSegmentsThanQ_differenceGreaterThanBoundary_level1", testPositionAllocate_PLessSegmentsThanQ_differenceGreaterThanBoundary_level1),
        ("testPositionAllocate_PLessSegmentsThanQ_differenceGreaterThanBoundary_level2", testPositionAllocate_PLessSegmentsThanQ_differenceGreaterThanBoundary_level2),
        ("testPositionAllocate_PLessSegmentsThanQ_differenceLessThanBoundary_level1", testPositionAllocate_PLessSegmentsThanQ_differenceLessThanBoundary_level1),
        ("testPositionAllocate_PLessSegmentsThanQ_differenceLessThanBoundary_level2", testPositionAllocate_PLessSegmentsThanQ_differenceLessThanBoundary_level2),
        ("testPositionAllocate_PLessSegmentsThanQ_qAtMax_level1", testPositionAllocate_PLessSegmentsThanQ_qAtMax_level1),
        ("testPositionAllocate_PLessSegmentsThanQ_qAtMax_level2", testPositionAllocate_PLessSegmentsThanQ_qAtMax_level2),
        ("testPositionAllocate_PLessSegmentsThanQ_qAtMaxMinusOne_level1", testPositionAllocate_PLessSegmentsThanQ_qAtMaxMinusOne_level1),
        ("testPositionAllocate_PLessSegmentsThanQ_qAtMaxMinusOne_level2", testPositionAllocate_PLessSegmentsThanQ_qAtMaxMinusOne_level2),
        ("testPositionAllocate_PLessSegmentsThanQ_qAtMin_level1_illegalState", testPositionAllocate_PLessSegmentsThanQ_qAtMin_level1_illegalState),
        ("testPositionAllocate_PLessSegmentsThanQ_qAtMin_level2_illegalState", testPositionAllocate_PLessSegmentsThanQ_qAtMin_level2_illegalState),
        ("testPositionAllocate_PLessSegmentsThanQ_qAtMinPlusOne_level1", testPositionAllocate_PLessSegmentsThanQ_qAtMinPlusOne_level1),
        ("testPositionAllocate_PLessSegmentsThanQ_qAtMinPlusOne_level2", testPositionAllocate_PLessSegmentsThanQ_qAtMinPlusOne_level2),
        ("testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_differenceGreaterThanBoundary_level1", testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_differenceGreaterThanBoundary_level1),
        ("testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_differenceGreaterThanBoundary_level2", testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_differenceGreaterThanBoundary_level2),
        ("testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_differenceLessThanBoundary_level1", testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_differenceLessThanBoundary_level1),
        ("testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_differenceSmallerThanBoundary_level2", testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_differenceSmallerThanBoundary_level2),
        ("testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_max_level1", testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_max_level1),
        ("testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_max_level2", testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_max_level2),
        ("testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_maxMinusOne_level1", testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_maxMinusOne_level1),
        ("testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_maxMinusOne_level2", testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_maxMinusOne_level2),
        ("testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_min_level1_illegalState", testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_min_level1_illegalState),
        ("testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_min_level2_illegalState", testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_min_level2_illegalState),
        ("testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_minPlusOne_level1", testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_minPlusOne_level1),
        ("testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_minPlusOne_level2", testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_minPlusOne_level2),
        ("testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_differenceGreaterThanBoundary_level1", testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_differenceGreaterThanBoundary_level1),
        ("testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_differenceGreaterThanBoundary_level2", testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_differenceGreaterThanBoundary_level2),
        ("testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_differenceLessThanBoundary_level2", testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_differenceLessThanBoundary_level2),
        ("testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_differenceSmallerThanBoundary_level1", testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_differenceSmallerThanBoundary_level1),
        ("testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_max_level1", testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_max_level1),
        ("testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_max_level2", testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_max_level2),
        ("testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_maxMinusOne_level1", testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_maxMinusOne_level1),
        ("testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_maxMinusOne_level2", testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_maxMinusOne_level2),
        ("testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_min_level1", testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_min_level1),
        ("testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_min_level2", testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_min_level2),
        ("testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_minPlusOne_level1", testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_minPlusOne_level1),
        ("testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_minPlusOne_level2", testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_minPlusOne_level2),
        ("testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_differenceGreaterThanBoundary_level1", testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_differenceGreaterThanBoundary_level1),
        ("testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_differenceGreaterThanBoundary_level2", testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_differenceGreaterThanBoundary_level2),
        ("testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_differenceLessThanBoundary_level1", testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_differenceLessThanBoundary_level1),
        ("testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_differenceLessThanBoundary_level2", testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_differenceLessThanBoundary_level2),
        ("testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_max_level1", testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_max_level1),
        ("testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_max_level2", testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_max_level2),
        ("testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_maxMinusOne_level1", testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_maxMinusOne_level1),
        ("testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_maxMinusOne_level2", testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_maxMinusOne_level2),
        ("testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_min_level1", testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_min_level1),
        ("testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_min_level2", testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_min_level2),
        ("testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_minPlusOne_level1", testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_minPlusOne_level1),
        ("testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_minPlusOne_level2", testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_minPlusOne_level2),
        ("testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_maxMinusOne_differenceGreaterThanBoundary_level1", testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_maxMinusOne_differenceGreaterThanBoundary_level1),
        ("testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_maxMinusOne_differenceGreaterThanBoundary_level2", testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_maxMinusOne_differenceGreaterThanBoundary_level2),
        ("testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_maxMinusOne_differenceLessThanBoundary_level1", testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_maxMinusOne_differenceLessThanBoundary_level1),
        ("testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_maxMinusOne_differenceLessThanBoundary_level2", testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_maxMinusOne_differenceLessThanBoundary_level2),
        ("testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_maxMinusOne_max_level1", testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_maxMinusOne_max_level1),
        ("testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_maxMinusOne_max_level2", testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_maxMinusOne_max_level2),
        ("testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_maxMinusOne_maxMinusOne_level2", testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_maxMinusOne_maxMinusOne_level2),
        ("testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_maxMinusOne_min_level1", testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_maxMinusOne_min_level1),
        ("testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_maxMinusOne_min_level2", testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_maxMinusOne_min_level2),
        ("testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_maxMinusOne_minPlusOne_level1", testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_maxMinusOne_minPlusOne_level1),
        ("testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_maxMinusOne_minPlusOne_level2", testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_maxMinusOne_minPlusOne_level2),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_differenceGreaterThanBoundary_level1", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_differenceGreaterThanBoundary_level1),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_differenceGreaterThanBoundary_level2", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_differenceGreaterThanBoundary_level2),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_differenceLessThanBoundary_level1", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_differenceLessThanBoundary_level1),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_differenceLessThanBoundary_level2", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_differenceLessThanBoundary_level2),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_max_level1", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_max_level1),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_max_level2", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_max_level2),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_maxMinusOne_level1", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_maxMinusOne_level1),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_maxMinusOne_level2", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_maxMinusOne_level2),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_differenceGreaterThanBoundary_level1", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_differenceGreaterThanBoundary_level1),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_differenceGreaterThanBoundary_level2", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_differenceGreaterThanBoundary_level2),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_differenceLessThanBoundary_level1", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_differenceLessThanBoundary_level1),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_differenceLessThanBoundary_level2", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_differenceLessThanBoundary_level2),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_level1", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_level1),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_level2", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_level2),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_max_level1", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_max_level1),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_max_level2", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_max_level2),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_maxMinusOne_level1", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_maxMinusOne_level1),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_maxMinusOne_level2", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_maxMinusOne_level2),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_min_level1", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_min_level1),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_min_level2", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_min_level2),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_minPlusOne_level1", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_minPlusOne_level1),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_minPlusOne_level2", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_minPlusOne_level2),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_differenceGreaterThanBoundary_level1", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_differenceGreaterThanBoundary_level1),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_differenceGreaterThanBoundary_level2", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_differenceGreaterThanBoundary_level2),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_differenceLessThanBoundary_level1", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_differenceLessThanBoundary_level1),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_differenceLessThanBoundary_level2", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_differenceLessThanBoundary_level2),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_level1", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_level1),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_level2", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_level2),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_max_level1", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_max_level1),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_max_level2", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_max_level2),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_maxMinusOne_level1", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_maxMinusOne_level1),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_maxMinusOne_level2", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_maxMinusOne_level2),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_min_level1", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_min_level1),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_min_level2", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_min_level2),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_minPlusOne_level1", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_minPlusOne_level1),
        ("testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_minPlusOne_level2", testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_minPlusOne_level2),
        ("testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_differenceGreaterThanBoundary_level0", testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_differenceGreaterThanBoundary_level0),
        ("testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_differenceGreaterThanBoundary_level1", testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_differenceGreaterThanBoundary_level1),
        ("testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_differenceLessThanBoundary_level0", testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_differenceLessThanBoundary_level0),
        ("testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_differenceLessThanBoundary_level1", testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_differenceLessThanBoundary_level1),
        ("testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_max_level0", testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_max_level0),
        ("testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_max_level1", testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_max_level1),
        ("testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_maxMinusOne_level0", testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_maxMinusOne_level0),
        ("testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_maxMinusOne_level1", testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_maxMinusOne_level1),
        ("testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_min_level0", testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_min_level0),
        ("testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_min_level1", testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_min_level1),
        ("testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_minPlusOne_level0", testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_minPlusOne_level0),
        ("testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_minPlusOne_level1", testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_minPlusOne_level1),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(LSEQTests.__allTests__LSEQTests),
        testCase(PositionAllocatorTests.__allTests__PositionAllocatorTests),
    ]
}
#endif