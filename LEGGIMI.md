# Berk Keyboard – istruzioni

STATO: codice scritto ma NON compilato né testato su iOS (qui non c'è Xcode).
Aspettati eventuali piccoli errori di compilazione da correggere.

## Opzione A – con XcodeGen (più rapida, serve un Mac)
1. Installa Xcode dall'App Store e Homebrew.
2. `brew install xcodegen`
3. Nella cartella del progetto: `xcodegen generate` → crea BerkKeyboard.xcodeproj
4. In project.yml sostituisci `com.tuonome` con un identificativo tuo (es. com.mario.rossi).

## Opzione B – a mano in Xcode
1. File › New › Project › iOS › App (SwiftUI), nome BerkKeyboard.
2. File › New › Target › Custom Keyboard Extension, nome BerkKeyboardExtension.
3. Sostituisci i file generati con quelli di App/ e Keyboard/; aggiungi Shared/RuneMap.swift a ENTRAMBI i target (spunta i due target in "Target Membership").
4. Nell'Info.plist dell'estensione: RequestsOpenAccess = NO, PrimaryLanguage = it-IT.
5. Elimina il file KeyboardViewController.swift di default per evitare duplicati.

## Firma e installazione su iPhone 12
1. Xcode › Settings › Accounts › aggiungi il tuo Apple ID (account gratuito va bene).
2. Seleziona il progetto › per ENTRAMBI i target: Signing & Capabilities › Automatically manage signing › scegli il tuo Team.
3. Bundle ID univoci; l'estensione deve iniziare con quello dell'app (es. app com.x.berk, estensione com.x.berk.keyboard).
4. iPhone: Impostazioni › Privacy e sicurezza › Modalità sviluppatore → attiva e riavvia. Collega il cavo, "Autorizza questo computer".
5. In Xcode scegli il tuo iPhone come destinazione e premi Run.
6. Se compare "sviluppatore non attendibile": Impostazioni › Generali › VPN e gestione dispositivo › fidati del profilo.
7. Con account gratuito l'app scade dopo 7 giorni (va reinstallata); con Developer Program a pagamento dura un anno.
8. Attiva la tastiera: Impostazioni › Generali › Tastiera › Tastiere › Aggiungi › Berk Keyboard.

## Font
Le rune (U+16A0–16FF) dovrebbero essere nel fallback di sistema iOS. Se vedi quadratini, aggiungi un font runico libero (es. Noto Sans Runic) all'estensione, includilo in Info.plist (UIAppFonts) e usalo in KeyboardViewController. Controlla soprattutto ᚲᚢ.

## Checklist test
Q in alto a sinistra, M in basso a destra; C/K, I/J, O/U/V inseriscono la lettera giusta; Q inserisce una sola "q"; Shift (tocco singolo, doppio = blocco maiuscole); Backspace anche tenuto premuto; prova in Messaggi, WhatsApp, Instagram, Safari.

## Limiti noti
Nessun suggerimento/correzione automatica, nessun emoji, nessun cambio lingua oltre al globo di sistema.
