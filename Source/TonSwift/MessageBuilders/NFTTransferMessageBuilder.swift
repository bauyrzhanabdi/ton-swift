import Foundation
import BigInt

public struct NFTTransferMessageBuilder {
    private init() {}
    
    public static func sendNFTTransfer(
        contract: WalletContract,
        sender: Address,
        seqno: UInt64,
        nftAddress: Address,
        recipientAddress: Address,
        isBounceable: Bool = true,
        transferAmount: BigUInt,
        timeout: UInt64?,
        forwardPayload: Cell?,
        signClosure: (WalletTransfer) async throws -> Data
    ) async throws -> String {
        let internalMessage = try NFTTransferMessage.internalMessage(
            nftAddress: nftAddress,
            nftTransferAmount: transferAmount,
            bounce: isBounceable,
            to: recipientAddress,
            from: sender,
            forwardPayload: forwardPayload
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
