import Foundation
import BigInt

public struct TonTransferMessageBuilder {
    private init() {}

    public static func sendTonTransfer(
        contract: WalletContract,
        sender: Address,
        seqno: UInt64,
        value: BigUInt,
        isMax: Bool,
        recipientAddress: Address,
        isBounceable: Bool = true,
        comment: String?,
        timeout: UInt64?,
        signClosure: (WalletTransfer) async throws -> Data
    ) async throws -> String {
        let internalMessage = try MessageRelaxed.internal(
                to: recipientAddress,
                value: value.magnitude,
                bounce: isBounceable,
                textPayload: comment ?? ""
            )
        let message = try await ExternalMessageTransferBuilder.externalMessageTransfer(
            contract: contract,
            sender: sender,
            sendMode: isMax ? .sendMaxTon() : .walletDefault(),
            seqno: seqno,
            internalMessages: [internalMessage],
            timeout: timeout,
            signClosure: signClosure
        )
        return message
    }
}
