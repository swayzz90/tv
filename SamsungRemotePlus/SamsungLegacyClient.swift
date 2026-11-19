import Foundation
import Network
import Combine

enum RemoteKey: String {
    case up = "KEY_UP", down = "KEY_DOWN", left = "KEY_LEFT", right = "KEY_RIGHT"
    case ok = "KEY_ENTER", back = "KEY_RETURN"
    case volumeUp = "KEY_VOLUP", volumeDown = "KEY_VOLDOWN", mute = "KEY_MUTE"
    case home = "KEY_SMARTHUB", source = "KEY_SOURCE", menu = "KEY_MENU"
    case play = "KEY_PLAY", pause = "KEY_PAUSE", powerOff = "KEY_POWEROFF"
}

/// Experimenteller Samsung-F-Series-Client, TCP 55000.
final class SamsungLegacyClient: ObservableObject {
    @Published private(set) var status = "Nicht verbunden"
    @Published private(set) var connected = false

    private let queue = DispatchQueue(label: "remote.legacy.network")
    private var socket: NWConnection?
    private var buffer = Data()
    private var authorized = false
    private var pending = [RemoteKey]()
    private var sending = false
    private var session = UUID()

    func connect(to rawIP: String) {
        let ip = rawIP.trimmingCharacters(in: .whitespacesAndNewlines)
        let octets = ip.split(separator: ".", omittingEmptySubsequences: false)
        guard octets.count == 4,
              octets.allSatisfy({ !$0.isEmpty && $0.count <= 3 && $0.allSatisfy({ $0 >= "0" && $0 <= "9" }) && Int($0).map({ $0 <= 255 }) == true }) else {
            publish("Ungültige TV-IP", connected: false)
            return
        }
        queue.async {
            self.reset()
            let current = self.session
            self.publish("Verbinde …", connected: false)
            let conn = NWConnection(host: NWEndpoint.Host(ip),
                                    port: NWEndpoint.Port(rawValue: 55000)!,
                                    using: .tcp)
            self.socket = conn
            conn.stateUpdateHandler = { [weak self, weak conn] state in
                guard let self = self, let conn = conn, self.socket === conn else { return }
                switch state {
                case .ready:
                    self.publish("Bitte am TV zulassen", connected: false)
                    self.receive(conn)
                    self.send(self.handshake(), via: conn)
                case .failed(let error):
                    self.fail("Verbindung fehlgeschlagen: \(error.localizedDescription)")
                default: break
                }
            }
            conn.start(queue: self.queue)
            self.queue.asyncAfter(deadline: .now() + 35) {
                if self.session == current && !self.authorized {
                    self.fail("Keine Freigabe vom TV erhalten")
                }
            }
        }
    }

    func press(_ key: RemoteKey) {
        queue.async {
            guard self.authorized else {
                self.publish("TV zuerst verbinden", connected: false)
                return
            }
            if self.pending.count < 30 { self.pending.append(key) }
            self.sendNext()
        }
    }

    private func sendNext() {
        guard authorized, !sending, !pending.isEmpty, let socket = socket else { return }
        sending = true
        let key = pending.removeFirst()
        var payload = Data([0, 0, 0])
        payload.append(Self.field(Data(key.rawValue.utf8)))
        send(Self.frame(payload), via: socket)
        queue.asyncAfter(deadline: .now() + 0.22) {
            self.sending = false
            self.sendNext()
        }
    }

    private func receive(_ conn: NWConnection) {
        conn.receive(minimumIncompleteLength: 1, maximumLength: 4096) { [weak self] data, _, done, error in
            guard let self = self, self.socket === conn else { return }
            if let data = data { self.buffer.append(data); self.parse() }
            if let error = error { self.fail(error.localizedDescription) }
            else if done { self.fail("TV hat Verbindung beendet") }
            else if self.socket === conn { self.receive(conn) }
        }
    }

    private func parse() {
        while buffer.count >= 5 {
            let nameLength = Int(buffer[1]) | Int(buffer[2]) << 8
            guard nameLength < 1024 else { fail("Ungültige TV-Antwort"); return }
            let header = 3 + nameLength + 2
            guard buffer.count >= header else { return }
            let size = Int(buffer[header - 2]) | Int(buffer[header - 1]) << 8
            guard size < 16384 else { fail("Ungültige Paketlänge"); return }
            guard buffer.count >= header + size else { return }
            let reply = Data(buffer[header..<(header + size)])
            buffer.removeSubrange(0..<(header + size))
            if reply == Data([0x64, 0, 1, 0]) {
                authorized = true
                publish("Verbunden", connected: true)
            } else if reply == Data([0x64, 0, 0, 0]) || reply.first == 0x65 {
                fail("Zugriff vom TV abgelehnt")
                return
            } else if reply.first == 0x0a {
                publish("Bitte am TV bestätigen", connected: false)
            }
        }
    }

    private func handshake() -> Data {
        var payload = Data([0x64, 0])
        payload.append(Self.field(Data("iPhone".utf8)))
        payload.append(Self.field(Data("RemotePlus".utf8)))
        payload.append(Self.field(Data("Samsung Remote+".utf8)))
        return Self.frame(payload)
    }

    private static func field(_ raw: Data, encode: Bool = true) -> Data {
        let value = encode ? raw.base64EncodedData() : raw
        precondition(value.count < 256)
        var result = Data([UInt8(value.count), 0])
        result.append(value)
        return result
    }

    private static func frame(_ payload: Data) -> Data {
        var result = Data([0, 0, 0])
        result.append(field(payload, encode: false))
        return result
    }

    private func send(_ data: Data, via conn: NWConnection) {
        conn.send(content: data, completion: .contentProcessed { [weak self] error in
            if let error = error {
                self?.queue.async { self?.fail(error.localizedDescription) }
            }
        })
    }

    private func fail(_ message: String) {
        reset()
        publish(message, connected: false)
    }

    private func reset() {
        session = UUID()
        socket?.stateUpdateHandler = nil
        socket?.cancel()
        socket = nil
        buffer.removeAll()
        pending.removeAll()
        authorized = false
        sending = false
    }

    private func publish(_ text: String, connected: Bool) {
        DispatchQueue.main.async {
            self.status = text
            self.connected = connected
        }
    }
}
