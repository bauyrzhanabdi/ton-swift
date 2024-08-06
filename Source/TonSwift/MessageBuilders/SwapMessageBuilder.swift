import Foundation
import BigInt

public struct SwapMessageBuilder {
    private init() {}
    
    public static func sendSwap(
        contract: WalletContract,
        sender: Address,
        seqno: UInt64,
        minAskAmount: BigUInt,
        offerAmount: BigUInt,
        jettonToWalletAddress: Address,
        jettonFromWalletAddress: Address,
        forwardAmount: BigUInt,
        attachedAmount: BigUInt,
        timeout: UInt64?,
        signClosure: (WalletTransfer) async throws -> Data
    ) async throws -> String {
        let internalMessage = try StonfiSwapMessage.internalMessage(
            userWalletAddress: sender,
            minAskAmount: minAskAmount,
            offerAmount: offerAmount,
            jettonFromWalletAddress: jettonFromWalletAddress,
            jettonToWalletAddress: jettonToWalletAddress,
            forwardAmount: forwardAmount,
            attachedAmount: attachedAmount
        )

        return try await ExternalMessageTransferBuilder
            .externalMessageTransfer(
                contract: contract,
                sender: sender,
                seqno: seqno, 
                internalMessages: [internalMessage],
                timeout: timeout,
                signClosure: signClosure
            )
    }
}
