public enum BluetoothMessagerError: Error {
    case noPeripheralConnected
    case sendingFailed
}

extension BluetoothMessagerError : LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noPeripheralConnected:
            return NSLocalizedString("I failed.", comment: "")
        case .sendingFailed:
            return NSLocalizedString("I failed.", comment: "")
        }
    }
}
