import Testing
@testable import AIMeterCore

@Test func testCoreVersion() async throws {
    #expect(AIMeterCoreVersion.version == "1.0.0")
}
