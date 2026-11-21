# Samsung Remote+ auf einem iPhone installieren – Windows

**Stand:** Experimentelle Testversion für Samsung UE46F6640SS (2013). Die App ist bereits kompiliert, aber die Verbindung zum Fernseher ist noch nicht auf echter Hardware getestet.

**Kosten:** Keine Premium-Gebühr für unsere App. Mit einem normalen Apple-Konto ist die Testsignierung in der Regel nur sieben Tage gültig. Für GitHub Actions können je nach Kontingent Kosten anfallen; vermeide unnötige Build-Wiederholungen.

## 1. Build-Datei herunterladen

1. Öffne [erfolgreichen GitHub Actions Build #6](https://github.com/swayzz90/tv/actions/runs/44526920610).
2. Ganz unten unter **Artifacts** auf `SamsungRemotePlus-unsigned-ipa` klicken (bei GitHub angemeldet).
3. Die heruntergeladene ZIP-Datei auf dem Windows-PC **entpacken**.
4. Im entpackten Ordner liegt `SamsungRemotePlus-unsigned.ipa`. **Die IPA selbst nicht entpacken.**
5. Die IPA auf das iPhone übertragen (z. B. über iCloud Drive, iCloud.com oder einen anderen normalen Dateitransfer), sodass sie in der iPhone-App **Dateien** geöffnet werden kann.

Die IPA wurde **ohne Apple-Signatur** erzeugt. Das ist beabsichtigt: AltStore Classic signiert sie beim Installieren mit deinem eigenen Apple-Konto.

## 2. AltStore Classic auf dem iPhone installieren

Nutze nur die offiziellen Links:
- [AltStore / AltServer](https://altstore.io/)
- [Offizielle Windows-Anleitung](https://faq.altstore.io/altstore-classic/how-to-install-altstore-windows)

1. Auf dem Windows-PC **iTunes und iCloud direkt von Apple** installieren, wie in der offiziellen AltStore-Windows-Anleitung beschrieben; nicht die Microsoft-Store-Version verwenden (die offizielle AltStore-Anleitung nennt auch einen Alternativweg für Store-iCloud).
2. Von **altstore.io** **AltServer für Windows** herunterladen, ZIP entpacken und Setup ausführen.
3. AltServer starten (Windows-Infobereich unten rechts, ggf. »Ausgeblendete Symbole anzeigen«).
4. iPhone per USB-Kabel an den PC anschließen, entsperren und bei »Diesem Computer vertrauen?« zustimmen.
5. In iTunes optional »Mit diesem iPhone über WLAN synchronisieren« aktivieren. Für die erste Installation reicht USB.
6. AltServer-Symbol anklicken → **Install AltStore** → dein iPhone wählen und mit deinem eigenen Apple-Konto die kostenlose App-Signierung einrichten. Das Apple-Passwort **niemals in GitHub oder ChatGPT** eingeben.

## 3. Apple-Entwicklerfreigabe auf dem iPhone

1. **Einstellungen → Allgemein → VPN & Geräteverwaltung** (der Menüname kann leicht abweichen): Profil deiner Apple-ID vertrauen.
2. Bei iOS 16 oder neuer unter **Einstellungen → Datenschutz & Sicherheit → Entwicklermodus** den Entwicklermodus einschalten und die nötige Bestätigung/Neustart durchführen, falls angezeigt.
3. AltStore **Classic** öffnen. (AltStore **PAL** ist ein anderes Produkt und nicht der Weg für unsere lokale IPA.)

## 4. Die Remote+-IPA mit AltStore installieren

1. AltServer auf dem Windows-PC geöffnet lassen. iPhone weiterhin über USB verbinden oder beide ins gleiche WLAN.
2. Die heruntergeladene `SamsungRemotePlus-unsigned.ipa` über **Dateien** auf dem iPhone erreichbar machen.
3. Auf dem iPhone AltStore Classic → **My Apps** → **+** → IPA auswählen.
4. Falls gefragt, mit der Apple-ID die Signierung erlauben; die Installation abschließen.
5. Auf dem Homescreen **Remote+** öffnen.

**Wichtig:** Bei einer kostenlosen Apple-ID muss die App typischerweise alle sieben Tage über AltStore mit AltServer erneuert werden (»Refresh All«). Die freie Apple-ID ist außerdem auf drei gleichzeitig aktive sideloaded Apps begrenzt.

## 5. Samsung-Fernseher verbinden

1. Den TV **mit der Originalfernbedienung einschalten**.
2. iPhone und Fernseher ins **gleiche Heimnetz** bringen.
3. TV-Menü → Netzwerk / Netzwerkstatus → die **IPv4-Adresse** finden (typisches Beispiel `192.168.178.30` – deine eigene Adresse kann abweichen).
4. In Remote+ auf **Einstellungen (Zahnrad)** tippen, die TV-IP eingeben und auf **Speichern und verbinden**.
5. Wenn auf dem Fernseher eine Anfrage erscheint, **Zugriff zulassen**.
6. Erst **Lauter / Leiser**, dann den zentralen **OK-/Pfeilkreis** testen.

Hinweis: Die App verwendet testweise das ältere Samsung-TCP-Protokoll auf Port **55000**. Wenn der Fernseher die Verbindung ablehnt oder nicht reagiert, muss das Protokoll für dein konkretes Gerät angepasst werden. **Einschalten aus ausgeschaltetem Zustand wird nicht unterstützt.** Ausschalten per Taste ist experimentell.

## Fehlersuche

- **AltStore lässt sich nicht installieren:** USB-Verbindung prüfen, »Diesem Computer vertrauen« bestätigen, iTunes/iCloud aus den offiziellen Quellen, AltServer als Administrator testen; [offizielle Fehlerhilfe](https://faq.altstore.io/altstore-classic/troubleshooting-guide).
- **Developer Mode fehlt:** Er erscheint bei neueren iOS-Versionen ggf. erst nach einer Entwicklungs-App-Installation/Installationsaufforderung. Offizielle Hinweise in der AltStore-Anleitung beachten.
- **AltStore findet AltServer nicht:** Beide Geräte gleiches WLAN / PC eingeschaltet und AltServer geöffnet / alternativ USB nutzen.
- **Remote+ meldet 'Keine Freigabe vom TV':** TV eingeschaltet, IP korrekt, gleiche Heimnetzverbindung, Anfrage auf dem Samsung bestätigen.
- **Remote+ meldet 'Verbindung fehlgeschlagen':** TV-IP überprüfen und in den TV-Einstellungen nach Netzwerk-Remote-Steuerung suchen.

**Keine Passwörter oder Apple-Token in GitHub hochladen.** Die IPA stammt aus deinem eigenen GitHub-Build.
