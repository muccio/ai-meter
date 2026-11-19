import Testing
import Foundation
@testable import AIMeterCore

@Suite("Quota Parsing Tests")
struct QuotaParsingTests {
    
    @Test func testParseDaemonConfig() throws {
        let json = """
        {
          "pid": 26463,
          "httpsPort": 49658,
          "httpPort": 49659,
          "lsVersion": "2.33.0",
          "csrfToken": "7b7a1e3b-c156-4803-9543-7cf88edcb030"
        }
        """.data(using: .utf8)!
        
        let config = try JSONDecoder().decode(DaemonConfig.self, from: json)
        #expect(config.pid == 26463)
        #expect(config.httpsPort == 49658)
        #expect(config.csrfToken == "7b7a1e3b-c156-4803-9543-7cf88edcb030")
    }

    @Test func testParseUserStatusAndModels() throws {
        let sampleJson = """
        {
          "userStatus": {
            "name": "Mario Rossi",
            "email": "mario@example.com",
            "planStatus": {
              "planInfo": {
                "teamsTier": "TEAMS_TIER_PRO",
                "planName": "Pro"
              },
              "availablePromptCredits": 500,
              "availableFlowCredits": 100
            },
            "cascadeModelConfigData": {
              "clientModelConfigs": [
                {
                  "modelId": "gemini-4-neon-high",
                  "label": "Gemini 4 Neon (High)",
                  "quotaInfo": {
                    "remainingFraction": 0.8467987,
                    "resetTime": "2026-11-19T18:59:30Z"
                  }
                },
                {
                  "modelId": "gemini-4-argon-medium",
                  "label": "Gemini 4 Argon (Medium)",
                  "quotaInfo": {
                    "remainingFraction": 0.41,
                    "resetTime": "2026-11-25T14:52:26Z"
                  }
                },
                {
                  "modelId": "gemini-4-carbon-disabled",
                  "label": "Gemini 4 Carbon"
                }
              ]
            }
          }
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(UserStatusResponse.self, from: sampleJson)
        #expect(response.userStatus.planStatus?.planInfo?.planName == "Pro")
        #expect(response.userStatus.planStatus?.availablePromptCredits == 500)
        #expect(response.userStatus.planStatus?.availableFlowCredits == 100)
        
        let models = response.extractModelQuotas()
        // The disabled model without quotaInfo is skipped or handled gracefully
        #expect(models.count == 2)
        
        let neon = models[0]
        #expect(neon.modelId == "gemini-4-neon-high")
        #expect(neon.percentage == 85)
        #expect(neon.remainingFraction == 0.8467987)
        #expect(neon.quotaStatus == .good)
        
        let argon = models[1]
        #expect(argon.percentage == 41)
        #expect(argon.quotaStatus == .warning)
    }
}
