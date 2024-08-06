import Foundation

public struct ExternalMessageTransferBuilder {
    private init() {}

    public static func externalMessageTransfer(
        contract: WalletContract,
        sender: Address,
        sendMode: SendMode = .walletDefault(),
        seqno: UInt64,
        internalMessages: [MessageRelaxed],
        timeout: UInt64?,
        signClosure: (WalletTransfer) async throws -> Data
    ) async throws -> String {
        let transferData = WalletTransferData(
            seqno: seqno,
            messages: internalMessages,
            sendMode: sendMode,
            timeout: timeout
        )
        let transfer = try contract.createTransfer(args: transferData, messageType: .ext)
        let signedTransfer = try await signClosure(transfer)
        let body = Builder()
        try body.store(data: signedTransfer)
        try body.store(transfer.signingMessage)
        let transferCell = try body.endCell()
        
        let externalMessage = Message.external(
            to: sender,
            stateInit: contract.stateInit,
            body: transferCell
        )
        let cell = try Builder().store(externalMessage).endCell()
        return try cell.toBoc().base64EncodedString()
    }
}
