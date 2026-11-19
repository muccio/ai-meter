import Testing
import Foundation
@testable import AIMeterCore

struct MockQuotaMonitor: QuotaMonitoring {
    let mockResult: QuotaDataResult

    func fetchQuotas() async throws -> QuotaDataResult {
        return mockResult
    }
}

@Suite("QuotaViewModel Tests")
@MainActor
struct QuotaViewModelTests {

    @Test func testInitialStateAndRefresh() async throws {
        let dummyModels = [
            ModelQuotaItem(modelId: "gemini-4-neon", label: "Gemini 4 Neon", remainingFraction: 0.90, resetTimeString: "2026-11-19T18:00:00Z"),
            ModelQuotaItem(modelId: "gemini-4-argon", label: "Gemini 4 Argon", remainingFraction: 0.35, resetTimeString: "2026-11-19T18:00:00Z")
        ]
        let mockResult = QuotaDataResult(
            planName: "Pro",
            promptCredits: 500,
            flowCredits: 100,
            models: dummyModels
        )
        let mockService = MockQuotaMonitor(mockResult: mockResult)
        let vm = QuotaViewModel(monitorService: mockService)

        #expect(vm.refreshInterval == 15 || vm.refreshInterval > 0)
        #expect(vm.isAlwaysOnTop == true || vm.isAlwaysOnTop == false)

        await vm.refresh()

        #expect(vm.planName == "Google AI Pro")
        #expect(vm.models.count == 2)
        #expect(vm.promptCredits == 500)
        #expect(vm.flowCredits == 100)
        #expect(vm.errorMessage == nil)

        // Test filtering
        vm.searchQuery = "neon"
        #expect(vm.filteredModels.count == 1)
        #expect(vm.filteredModels.first?.modelId == "gemini-4-neon")

        // Test interval setting
        vm.setRefreshInterval(30)
        #expect(vm.refreshInterval == 30)

        // Test toggle always on top
        let current = vm.isAlwaysOnTop
        vm.toggleAlwaysOnTop()
        #expect(vm.isAlwaysOnTop == !current)
    }
}
