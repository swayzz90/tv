# Samsung Remote+ für iPhone

Eine persönliche, kostenlose WLAN-Fernbedienung für **Samsung UE46F6640SS (F-Serie, 2013)**.

## Oberfläche

- Großer runder Navigationskreis (hoch, runter, links, rechts, OK) **in der Mitte**
- Lauter, leiser und stumm **links**
- Zurück, Smart Hub und Quelle **rechts**
- Menü, Play und Pause darunter
- Ausschalten oben; **kein Senderwechsel**, keine Werbung, kein Abo

## Status

**Experimentelle Version 0.1.** Die iPhone-App und das alte Samsung-TCP-Protokoll (Port 55000) müssen noch auf einem echten Gerät getestet werden. Das Ein**schalten** aus Standby wird nicht unterstützt; Ausschalten kann funktionieren.

## Bauen und auf dem iPhone installieren

Der GitHub-Workflow unter **Actions → iOS Build** erstellt einen Simulator-Build und versucht, eine **unsignierte** iPhone-IPA zu erzeugen. Diese IPA ist **noch nicht installierbar**: Sie muss auf Windows z. B. mit AltStore/AltServer und einem eigenen Apple-Konto signiert werden. Ob das auf deinem iPhone funktioniert, ist noch zu testen. Die kostenlose Apple-Signierung läuft normalerweise nach sieben Tagen ab. Je nach GitHub-Kontingent können macOS-Runner Kosten verursachen.

Für Mac-Nutzer: `brew install xcodegen`, dann `xcodegen generate`, Projekt in Xcode öffnen und mit dem eigenen Personal Team signieren.

## Verbindung

1. iPhone und TV mit demselben Heimnetz verbinden.
2. TV einschalten und unter **Menü → Netzwerk** seine IPv4-Adresse ermitteln.
3. In der App die IP eintragen und auf „Speichern und verbinden“ tippen.
4. Die Zugriffsanfrage am Fernseher bestätigen.

Der Quellcode verwendet ausschließlich Apple-Frameworks und das dokumentierte historische Samsung-Protokoll (vgl. [samsungctl](https://github.com/Ape/samsungctl/blob/master/samsungctl/remote_legacy.py)). Kein offizielles Samsung-Produkt. **Keine Zugangsdaten in dieses öffentliche Repository hochladen.**
