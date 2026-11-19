import SwiftUI
import UIKit

private enum Theme {
    static let bg = Color(red: 0.05, green: 0.06, blue: 0.09)
    static let panel = Color(red: 0.10, green: 0.12, blue: 0.16)
    static let key = Color(red: 0.17, green: 0.19, blue: 0.24)
    static let accent = Color(red: 0.35, green: 0.65, blue: 0.98)
}

struct RemoteView: View {
    @AppStorage("tvIP") private var ip = ""
    @StateObject private var remote = SamsungLegacyClient()
    @State private var settings = false
    @State private var confirmPower = false

    var body: some View {
        GeometryReader { geometry in
            let wheel = min(220, max(136, geometry.size.width - 162))
            ZStack {
                Theme.bg.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 22) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Remote+").font(.system(size: 31, weight: .bold, design: .rounded))
                                Text("Samsung UE46F6640 · 2013")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button { settings = true } label: {
                                Image(systemName: "gearshape.fill")
                                    .frame(width: 46, height: 46)
                            }
                            Button { confirmPower = true } label: {
                                Image(systemName: "power")
                                    .foregroundStyle(.red)
                                    .frame(width: 46, height: 46)
                            }
                        }
                        HStack {
                            Circle().fill(remote.connected ? .green : .orange)
                                .frame(width: 9, height: 9)
                            Text(remote.status).font(.subheadline)
                            Spacer()
                            Button("Verbinden") { connectOrSettings() }
                                .font(.subheadline)
                        }
                        .padding(16)
                        .background(Theme.panel, in: RoundedRectangle(cornerRadius: 18))

                        VStack(spacing: 23) {
                            HStack(alignment: .center, spacing: 6) {
                                VStack(spacing: 13) {
                                    Text("VOL").font(.caption.bold()).foregroundStyle(.secondary)
                                    side("plus", "Lauter", .volumeUp)
                                    side("minus", "Leiser", .volumeDown)
                                    side("speaker.slash", "Stumm", .mute)
                                }.frame(width: 55)

                                Spacer(minLength: 0)
                                wheelView(size: wheel)
                                Spacer(minLength: 0)

                                VStack(spacing: 13) {
                                    Text("TV").font(.caption.bold()).foregroundStyle(.secondary)
                                    side("arrow.uturn.backward", "Zurück", .back)
                                    side("house.fill", "Smart Hub", .home)
                                    side("rectangle.on.rectangle", "Quelle", .source)
                                }.frame(width: 55)
                            }
                            HStack(spacing: 10) {
                                bottom("Menü", "line.3.horizontal", .menu)
                                bottom("Play", "play.fill", .play)
                                bottom("Pause", "pause.fill", .pause)
                            }
                        }
                        .padding(12)
                        .padding(.vertical, 24)
                        .background(Theme.panel, in: RoundedRectangle(cornerRadius: 28))
                        Text("Keine Sender-Tasten · Keine Werbung · Kein Abo")
                            .font(.caption).foregroundStyle(.secondary)
                        Text("Der Power-Knopf schaltet nur aus. Einschalten über WLAN wird nicht unterstützt.")
                            .font(.caption2).foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(16)
                    .frame(maxWidth: 480)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $settings) {
            NavigationStack {
                Form {
                    Section("TV-IP-Adresse") {
                        TextField("192.168.178.35", text: $ip)
                            .keyboardType(.decimalPad)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        Button("Speichern und verbinden") {
                            settings = false
                            remote.connect(to: ip)
                        }
                    }
                    Section {
                        Text("TV und iPhone müssen im selben WLAN sein. IP unter Menü → Netzwerk am TV ablesen. Verbindung am Fernseher bestätigen.")
                    }
                }
                .navigationTitle("TV verbinden")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Fertig") { settings = false }
                    }
                }
            }
        }
        .confirmationDialog("Fernseher ausschalten?", isPresented: $confirmPower) {
            Button("Ausschalten", role: .destructive) { press(.powerOff) }
        }
        .onAppear { if !ip.isEmpty { remote.connect(to: ip) } else { settings = true } }
    }

    private func wheelView(size: CGFloat) -> some View {
        ZStack {
            Circle().fill(Theme.key)
            Circle().stroke(.white.opacity(0.12), lineWidth: 1.5)
            wheelButton("chevron.up", .up).offset(y: -size * 0.35)
            wheelButton("chevron.down", .down).offset(y: size * 0.35)
            wheelButton("chevron.left", .left).offset(x: -size * 0.35)
            wheelButton("chevron.right", .right).offset(x: size * 0.35)
            Button { press(.ok) } label: {
                Text("OK").font(.headline.bold())
                    .frame(width: size * 0.34, height: size * 0.34)
                    .background(Theme.accent, in: Circle())
            }
            .accessibilityLabel("OK")
        }
        .frame(width: size, height: size)
    }

    private func wheelButton(_ icon: String, _ key: RemoteKey) -> some View {
        Button { press(key) } label: {
            Image(systemName: icon).font(.title3.bold())
                .frame(width: 48, height: 48)
                .contentShape(Rectangle())
        }
        .accessibilityLabel(key.rawValue)
    }

    private func side(_ icon: String, _ title: String, _ key: RemoteKey) -> some View {
        Button { press(key) } label: {
            Image(systemName: icon).font(.title3)
                .frame(width: 52, height: 55)
                .background(Theme.key, in: RoundedRectangle(cornerRadius: 15))
        }
        .accessibilityLabel(title)
    }

    private func bottom(_ title: String, _ icon: String, _ key: RemoteKey) -> some View {
        Button { press(key) } label: {
            VStack(spacing: 7) {
                Image(systemName: icon).font(.title3)
                Text(title).font(.caption)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .background(Theme.key, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private func press(_ key: RemoteKey) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        remote.press(key)
    }

    private func connectOrSettings() {
        if ip.isEmpty { settings = true } else { remote.connect(to: ip) }
    }
}
