import Foundation
import BigInt

public struct TonConnectTransferMessageBuilder {
    private init() {}

    public struct Payload {
        public let value: BigInt
        public let recipientAddress: Address
        public let stateInit: String?
        public let payload: String?

        public init(
            value: BigInt,
            recipientAddress: Address,
            stateInit: String?,
            payload: String?
        ) {
            self.value = value
            self.recipientAddress = recipientAddress
            self.stateInit = stateInit
            self.payload = payload
        }
    }

    public static func sendTonConnectTransfer(
        contract: WalletContract,
        sender: Address,
        seqno: UInt64,
        payloads: [Payload],
        timeout: UInt64?,
        signClosure: (WalletTransfer) async throws -> Data
    ) async throws -> String {
        let messages = try payloads.map { payload in
            var stateInit: StateInit?
            if let stateInitString = payload.stateInit {
                stateInit = try StateInit.loadFrom(
                    slice: try Cell
                        .fromBase64(src: stateInitString)
                        .toSlice()
                )
            }
            var body: Cell = .empty
            if let messagePayload = payload.payload {
                body = try Cell.fromBase64(src: messagePayload)
            }
            return MessageRelaxed.internal(
                to: payload.recipientAddress,
                value: payload.value.magnitude,
                bounce: false,
                stateInit: stateInit,
                body: body)
        }
        return try await ExternalMessageTransferBuilder
            .externalMessageTransfer(
                contract: contract,
                sender: sender,
                seqno: seqno, 
                internalMessages: messages,
                timeout: timeout,
                signClosure: signClosure
            )
    }
}
