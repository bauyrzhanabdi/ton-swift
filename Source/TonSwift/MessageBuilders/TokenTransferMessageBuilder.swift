import Foundation
import BigInt

public struct TokenTransferMessageBuilder {
    public init() {}
    
    public static func sendTokenTransfer(
        contract: WalletContract,
        sender: Address,
        seqno: UInt64,
        jettonWalletAddress: Address,
        value: BigUInt,
        recipientAddress: Address,
        isBounceable: Bool = true,
        comment: String?,
        timeout: UInt64?,
        signClosure: (WalletTransfer
        ) async throws -> Data
    ) async throws -> String {
        let internalMessage = try JettonTransferMessage.internalMessage(
            jettonWalletAddress: jettonWalletAddress,
            amount: BigInt(value),
            bounce: isBounceable,
            to: recipientAddress,
            from: sender,
            comment: comment
        )
        let message = try await ExternalMessageTransferBuilder
            .externalMessageTransfer(
                contract: contract,
                sender: sender,
                seqno: seqno,
                internalMessages: [internalMessage],
                timeout: timeout,
                signClosure: signClosure
            )
        return message
    }
}
