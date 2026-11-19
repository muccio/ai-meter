import Testing
import Foundation
@testable import AIMeterCore

@Suite("Quota Group (5h & Weekly) Parsing Tests")
struct QuotaGroupParsingTests {

    @Test func testParseUserQuotaSummary() throws {
        let sampleJson = """
        {
          "response": {
            "groups": [
              {
                "displayName": "Gemini Models",
                "description": "Models: Gemini 4 Neon, etc.",
                "buckets": [
                  {
                    "bucketId": "gemini-weekly",
                    "displayName": "Weekly Limit Remaining",
                    "window": "weekly",
                    "remainingFraction": 0.748,
                    "resetTime": "2026-11-25T15:24:12Z"
                  },
                  {
                    "bucketId": "gemini-5h",
                    "displayName": "Five Hour Limit Remaining",
                    "window": "5h",
                    "remainingFraction": 0.645,
                    "resetTime": "2026-11-19T18:59:30Z"
                  }
                ]
              },
              {
                "displayName": "Gemini 4 Argon",
                "buckets": [
                  {
                    "bucketId": "gemini-argon-wtu-weekly",
                    "displayName": "Gemini 4 Argon Weekly Limit",
                    "window": "weekly",
                    "remainingFraction": 0.414,
                    "resetTime": "2026-11-25T14:52:26Z"
                  }
                ]
              }
            ]
          }
        }
        """.data(using: .utf8)!

        let summary = try JSONDecoder().decode(UserQuotaSummaryResponse.self, from: sampleJson)
        let groups = summary.extractQuotaGroups()
        #expect(groups.count == 2)

        let geminiGroup = groups[0]
        #expect(geminiGroup.displayName == "Gemini Models")
        #expect(geminiGroup.fiveHourBucket?.percentage == 65)
        #expect(geminiGroup.weeklyBucket?.percentage == 75)

        let argonGroup = groups[1]
        #expect(argonGroup.fiveHourBucket == nil)
        #expect(argonGroup.weeklyBucket?.percentage == 41)
    }
}
