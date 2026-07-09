import UIKit

final class FormFieldCell: UITableViewCell {
    static let reuseIdentifier = "FormFieldCell"

    let titleLabel = UILabel()
    let valueField = UITextField()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        titleLabel.font = .preferredFont(forTextStyle: .body)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        valueField.borderStyle = .none
        valueField.font = .preferredFont(forTextStyle: .body)
        valueField.textAlignment = .right

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueField])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, text: String, placeholder: String, keyboardType: UIKeyboardType = .default) {
        titleLabel.text = title
        valueField.text = text
        valueField.placeholder = placeholder
        valueField.keyboardType = keyboardType
        valueField.autocapitalizationType = .none
        valueField.autocorrectionType = .no
    }
}

final class FormMultilineCell: UITableViewCell, UITextViewDelegate {
    static let reuseIdentifier = "FormMultilineCell"

    let titleLabel = UILabel()
    let valueView = UITextView()
    var onTextChanged: ((String) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        titleLabel.font = .preferredFont(forTextStyle: .body)

        valueView.font = .preferredFont(forTextStyle: .body)
        valueView.isScrollEnabled = false
        valueView.delegate = self
        valueView.backgroundColor = .clear

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueView])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            valueView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, text: String) {
        titleLabel.text = title
        valueView.text = text
    }

    func textViewDidChange(_ textView: UITextView) {
        onTextChanged?(textView.text)
    }
}

final class FormSwitchCell: UITableViewCell {
    static let reuseIdentifier = "FormSwitchCell"

    let titleLabel = UILabel()
    let toggle = UISwitch()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        titleLabel.font = .preferredFont(forTextStyle: .body)

        let stack = UIStackView(arrangedSubviews: [titleLabel, toggle])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, isOn: Bool) {
        titleLabel.text = title
        toggle.isOn = isOn
    }
}
