import Foundation



/// Represents `MsgAddress` structure per TL-B definition:
/// Note that in TON optional address is represented by MsgAddressExt
/// ```
/// addr_none$00 = MsgAddressExt;
/// addr_extern$01 len:(## 9) external_address:(bits len)
///              = MsgAddressExt;
/// anycast_info$_ depth:(#<= 30) { depth >= 1 }
///    rewrite_pfx:(bits depth) = Anycast;
/// addr_std$10 anycast:(Maybe Anycast)
///    workchain_id:int8 address:bits256  = MsgAddressInt;
/// addr_var$11 anycast:(Maybe Anycast) addr_len:(## 9)
///    workchain_id:int32 address:(bits addr_len) = MsgAddressInt;
/// _ _:MsgAddressInt = MsgAddress;
/// _ _:MsgAddressExt = MsgAddress;
/// ```
///
enum AnyAddress {
    case none
    case internalAddr(Address)
    case externalAddr(ExternalAddress)
    
    /// Unwraps to an optional internal address. Throws if it is an external address.
    public func asInternal() throws -> Address? {
        switch self {
        case .none: return nil;
        case .internalAddr(let addr): return addr;
        case .externalAddr(_): throw TonError.custom("Expected internal address")
        }
    }
    
    /// Unwraps to an external address. Throws if it is an internal address.
    public func asExternal() throws -> ExternalAddress? {
        switch self {
        case .none: return nil;
        case .internalAddr(_): throw TonError.custom("Expected external address")
        case .externalAddr(let addr): return addr;
        }
    }
}

extension AnyAddress: Writable {
    func writeTo(builder: Builder) throws {
        switch self {
        case .none:
            try builder.storeUint(UInt64(0), bits: 2)
            break
        case .internalAddr(let addr):
            try addr.writeTo(builder: builder)
            break
        case .externalAddr(let addr):
            // TBD
            break
        }
    }
}