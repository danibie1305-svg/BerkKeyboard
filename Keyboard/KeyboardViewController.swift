import UIKit

private enum Theme {
    static let background = UIColor(red: 0.106, green: 0.110, blue: 0.118, alpha: 1)
    static let key        = UIColor(red: 0.227, green: 0.239, blue: 0.251, alpha: 1) // antracite
    static let special    = UIColor(red: 0.165, green: 0.173, blue: 0.184, alpha: 1)
    static let pressed    = UIColor(red: 0.33,  green: 0.345, blue: 0.36,  alpha: 1)
    static let ivory      = UIColor(red: 0.949, green: 0.910, blue: 0.816, alpha: 1)
}

private final class KeyButton: UIButton {
    var baseColor = Theme.key { didSet { backgroundColor = baseColor } }
    override var isHighlighted: Bool {
        didSet { backgroundColor = isHighlighted ? Theme.pressed : baseColor }
    }
}

final class KeyboardViewController: UIInputViewController {

    private enum Layer { case letters, numbers, symbols }
    private enum ShiftState { case off, on, locked }

    private var layer: Layer = .letters
    private var shiftState: ShiftState = .off
    private var lastShiftTap = Date.distantPast
    private var shiftButton: KeyButton?
    private var deleteDelay: Timer?
    private var deleteRepeat: Timer?
    private let spacing: CGFloat = 6

    override func viewDidLoad() {
        super.viewDidLoad()
        let h = view.heightAnchor.constraint(equalToConstant: 226)
        h.priority = UILayoutPriority(999)
        h.isActive = true
        buildLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateAutoShift()
    }

    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        updateAutoShift()
    }

    // MARK: Layout

    private func buildLayout() {
        stopDelete()
        view.subviews.forEach { $0.removeFromSuperview() }
        view.backgroundColor = Theme.background
        shiftButton = nil

        let root = UIStackView()
        root.axis = .vertical
        root.spacing = 10
        root.distribution = .fillEqually
        root.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(root)
        NSLayoutConstraint.activate([
            root.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            root.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -4),
            root.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 3),
            root.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -3)
        ])

        let rows: [[String]]
        switch layer {
        case .letters:
            rows = [Array("QWERTYUIOP").map(String.init),
                    Array("ASDFGHJKL").map(String.init),
                    Array("ZXCVBNM").map(String.init)]
        case .numbers:
            rows = [Array("1234567890").map(String.init),
                    ["-", "/", ":", ";", "(", ")", "€", "&", "@", "\""],
                    [".", ",", "?", "!", "'"]]
        case .symbols:
            rows = [["[", "]", "{", "}", "#", "%", "^", "*", "+", "="],
                    ["_", "\\", "|", "~", "<", ">", "$", "£", "¥", "•"],
                    [".", ",", "?", "!", "'"]]
        }

        // Riga 1
        let row1 = makeRow()
        let keys1 = rows[0].map { makeCharKey($0) }
        keys1.forEach { row1.addArrangedSubview($0) }
        root.addArrangedSubview(row1)
        let ref = keys1[0]
        keys1.dropFirst().forEach { equalWidth($0, ref) }

        // Riga 2 (con mezzi spazi laterali)
        let row2 = makeRow()
        let half1 = UIView(), half2 = UIView()
        for h in [half1, half2] {
            let c = h.widthAnchor.constraint(equalTo: ref.widthAnchor, multiplier: 0.5, constant: -spacing / 2)
            c.priority = UILayoutPriority(999); c.isActive = true
        }
        row2.addArrangedSubview(half1)
        let keys2 = rows[1].map { makeCharKey($0) }
        keys2.forEach { row2.addArrangedSubview($0); equalWidth($0, ref) }
        row2.addArrangedSubview(half2)
        root.addArrangedSubview(row2)

        // Riga 3
        let row3 = makeRow()
        let left: KeyButton
        if layer == .letters {
            left = makeSpecial(symbol: "shift") { [weak self] in self?.tapShift() }
            shiftButton = left
        } else {
            let t = layer == .numbers ? "#+=" : "123"
            left = makeSpecial(title: t, fontSize: 16) { [weak self] in
                self?.layer = (self?.layer == .numbers) ? .symbols : .numbers
                self?.buildLayout()
            }
        }
        let back = makeSpecial(symbol: "delete.left") {}
        attachBackspace(back)
        row3.addArrangedSubview(left)
        let keys3 = rows[2].map { makeCharKey($0) }
        let mult: CGFloat = layer == .letters ? 1.0 : 1.4
        keys3.forEach { row3.addArrangedSubview($0); equalWidth($0, ref, multiplier: mult) }
        row3.addArrangedSubview(back)
        let eq = left.widthAnchor.constraint(equalTo: back.widthAnchor)
        eq.priority = UILayoutPriority(999); eq.isActive = true
        root.addArrangedSubview(row3)

        // Riga 4
        let row4 = makeRow()
        let toggleTitle = layer == .letters ? "123" : "ABC"
        let toggle = makeSpecial(title: toggleTitle, fontSize: 16) { [weak self] in
            guard let self = self else { return }
            self.layer = (self.layer == .letters) ? .numbers : .letters
            self.buildLayout()
        }
        equalWidth(toggle, ref, multiplier: 1.3)
        row4.addArrangedSubview(toggle)
        if needsInputModeSwitchKey {
            let globe = makeSpecial(symbol: "globe") {}
            globe.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
            equalWidth(globe, ref, multiplier: 1.0)
            row4.addArrangedSubview(globe)
        }
        let space = makeSpecial(title: "spazio", fontSize: 16, dark: false) { [weak self] in
            self?.textDocumentProxy.insertText(" ")
        }
        space.setContentHuggingPriority(UILayoutPriority(1), for: .horizontal)
        row4.addArrangedSubview(space)
        let ret = makeSpecial(symbol: "return") { [weak self] in
            self?.textDocumentProxy.insertText("\n")
        }
        equalWidth(ret, ref, multiplier: 2.0)
        row4.addArrangedSubview(ret)
        root.addArrangedSubview(row4)

        refreshShiftAppearance()
    }

    private func makeRow() -> UIStackView {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = spacing
        s.distribution = .fill
        return s
    }

    private func equalWidth(_ v: UIView, _ ref: UIView, multiplier: CGFloat = 1) {
        let c = v.widthAnchor.constraint(equalTo: ref.widthAnchor, multiplier: multiplier)
        c.priority = UILayoutPriority(999)
        c.isActive = true
    }

    // MARK: Tasti

    private func baseButton() -> KeyButton {
        let b = KeyButton(type: .custom)
        b.layer.cornerRadius = 5
        b.layer.shadowColor = UIColor.black.cgColor
        b.layer.shadowOffset = CGSize(width: 0, height: 1)
        b.layer.shadowOpacity = 0.6
        b.layer.shadowRadius = 0
        b.setTitleColor(Theme.ivory, for: .normal)
        b.tintColor = Theme.ivory
        b.baseColor = Theme.key
        return b
    }

    private func makeCharKey(_ value: String) -> KeyButton {
        let b = baseButton()
        if layer == .letters {
            let rune = RuneMap.rune(for: value)
            b.setTitle(rune, for: .normal)
            b.titleLabel?.font = UIFont.systemFont(ofSize: rune.count > 1 ? 17 : 24)
        } else {
            b.setTitle(value, for: .normal)
            b.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        }
        b.addAction(UIAction { [weak self] _ in self?.insert(value) }, for: .touchUpInside)
        return b
    }

    private func makeSpecial(title: String? = nil, symbol: String? = nil, fontSize: CGFloat = 16,
                             dark: Bool = true, action: @escaping () -> Void) -> KeyButton {
        let b = baseButton()
        b.baseColor = dark ? Theme.special : Theme.key
        if let t = title {
            b.setTitle(t, for: .normal)
            b.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        }
        if let s = symbol {
            b.setImage(UIImage(systemName: s), for: .normal)
        }
        b.addAction(UIAction { _ in action() }, for: .touchUpInside)
        return b
    }

    // MARK: Inserimento

    private func insert(_ value: String) {
        if layer == .letters {
            let text = (shiftState == .off) ? value.lowercased() : value.uppercased()
            textDocumentProxy.insertText(text)   // sempre UNA lettera latina, anche per Q
            if shiftState == .on { shiftState = .off; refreshShiftAppearance() }
        } else {
            textDocumentProxy.insertText(value)
        }
    }

    // MARK: Shift

    private func tapShift() {
        let now = Date()
        if now.timeIntervalSince(lastShiftTap) < 0.35 {
            shiftState = .locked
        } else {
            shiftState = (shiftState == .off) ? .on : .off
        }
        lastShiftTap = now
        refreshShiftAppearance()
    }

    private func refreshShiftAppearance() {
        guard let b = shiftButton else { return }
        let name: String
        switch shiftState {
        case .off: name = "shift"
        case .on: name = "shift.fill"
        case .locked: name = "capslock.fill"
        }
        b.setImage(UIImage(systemName: name), for: .normal)
        b.baseColor = (shiftState == .off) ? Theme.special : Theme.key
    }

    private func updateAutoShift() {
        guard layer == .letters, shiftState != .locked else { return }
        let proxy = textDocumentProxy
        guard proxy.autocapitalizationType == .sentences else { return }
        let before = proxy.documentContextBeforeInput ?? ""
        if before.isEmpty || before.hasSuffix(". ") || before.hasSuffix("? ") || before.hasSuffix("! ") || before.hasSuffix("\n") {
            shiftState = .on
        }
        refreshShiftAppearance()
    }

    // MARK: Backspace con ripetizione

    private func attachBackspace(_ b: KeyButton) {
        b.addAction(UIAction { [weak self] _ in self?.startDelete() }, for: .touchDown)
        for ev: UIControl.Event in [.touchUpInside, .touchUpOutside, .touchCancel] {
            b.addAction(UIAction { [weak self] _ in self?.stopDelete() }, for: ev)
        }
    }

    private func startDelete() {
        textDocumentProxy.deleteBackward()
        deleteDelay = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { [weak self] _ in
            self?.deleteRepeat = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { [weak self] _ in
                self?.textDocumentProxy.deleteBackward()
            }
        }
    }

    private func stopDelete() {
        deleteDelay?.invalidate(); deleteDelay = nil
        deleteRepeat?.invalidate(); deleteRepeat = nil
    }
}
