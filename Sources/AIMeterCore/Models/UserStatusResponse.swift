import Foundation

public struct UserStatusResponse: Codable, Sendable {
    public let userStatus: UserStatusDetail

    public struct UserStatusDetail: Codable, Sendable {
        public let name: String?
        public let email: String?
        public let planStatus: PlanStatus?
        public let cascadeModelConfigData: CascadeModelConfigData?
    }

    public struct PlanStatus: Codable, Sendable {
        public let planInfo: PlanInfo?
        public let availablePromptCredits: Int?
        public let availableFlowCredits: Int?
    }

    public struct PlanInfo: Codable, Sendable {
        public let planName: String?
        public let teamsTier: String?
    }

    public struct CascadeModelConfigData: Codable, Sendable {
        public let clientModelConfigs: [ClientModelConfig]?
    }

    public struct ClientModelConfig: Codable, Sendable {
        public let modelId: String?
        public let label: String?
        public let quotaInfo: QuotaInfoDetail?
    }

    public struct QuotaInfoDetail: Codable, Sendable {
        public let remainingFraction: Double?
        public let resetTime: String?
    }

    public func extractModelQuotas() -> [ModelQuotaItem] {
        guard let configs = userStatus.cascadeModelConfigData?.clientModelConfigs else {
            return []
        }
        
        var result: [ModelQuotaItem] = []
        for config in configs {
            guard let modelId = config.modelId,
                  let label = config.label,
                  let quota = config.quotaInfo,
                  let fraction = quota.remainingFraction,
                  !fraction.isNaN else {
                continue
            }
            let item = ModelQuotaItem(
                modelId: modelId,
                label: label,
                remainingFraction: fraction,
                resetTimeString: quota.resetTime
            )
            result.append(item)
        }
        return result
    }
}
