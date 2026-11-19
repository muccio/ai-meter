import Testing
@testable import AIMeterCore

@Test func testCoreVersion() async throws {
    #expect(AIMeterCoreVersion.version == "1.1.0")
}
