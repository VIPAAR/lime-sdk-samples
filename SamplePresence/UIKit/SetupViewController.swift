import UIKit

final class SetupViewController: UITableViewController {
    private let flowController: DemoFlowController
    private var pin = ""

    private enum Section: Int, CaseIterable {
        case authToken
        case createSession
        case retrieveSession
    }

    init(flowController: DemoFlowController) {
        self.flowController = flowController
        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Setup Session"
        tableView.register(FormFieldCell.self, forCellReuseIdentifier: FormFieldCell.reuseIdentifier)
        bindFlowController()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        flowController.errorMessage == nil ? Section.allCases.count : Section.allCases.count + 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section) {
        case .authToken: return "Auth Token"
        case .createSession: return "Create Session"
        case .retrieveSession: return "Retrieve Session"
        default: return nil
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == Section.allCases.count {
            return 1
        }
        switch Section(rawValue: section) {
        case .authToken: return 1
        case .createSession: return 2
        case .retrieveSession: return 2
        default: return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == Section.allCases.count {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "ErrorCell")
            cell.selectionStyle = .none
            cell.textLabel?.text = flowController.errorMessage
            cell.textLabel?.textColor = .systemRed
            cell.textLabel?.numberOfLines = 0
            return cell
        }

        switch Section(rawValue: indexPath.section) {
        case .authToken:
            let cell = UITableViewCell(style: .default, reuseIdentifier: "TokenCell")
            cell.selectionStyle = .none
            cell.textLabel?.font = .preferredFont(forTextStyle: .footnote)
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = flowController.session.authToken
            return cell
        case .createSession:
            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: FormFieldCell.reuseIdentifier, for: indexPath) as? FormFieldCell else {
                    return UITableViewCell()
                }
                cell.configure(
                    title: "Contact Email:",
                    text: flowController.session.contactEmail,
                    placeholder: "contact@example.com",
                    keyboardType: .emailAddress
                )
                cell.valueField.addAction(UIAction { [weak self] _ in
                    self?.flowController.session.contactEmail = cell.valueField.text ?? ""
                }, for: .editingChanged)
                return cell
            }
            return actionCell(title: flowController.isBusy ? "Creating…" : "Create Session", enabled: !flowController.isBusy)
        case .retrieveSession:
            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: FormFieldCell.reuseIdentifier, for: indexPath) as? FormFieldCell else {
                    return UITableViewCell()
                }
                cell.configure(title: "PIN:", text: pin, placeholder: "Required")
                cell.valueField.addAction(UIAction { [weak self] action in
                    guard let field = action.sender as? UITextField else { return }
                    self?.pin = field.text ?? ""
                }, for: .editingChanged)
                return cell
            }
            return actionCell(
                title: flowController.isBusy ? "Retrieving…" : "Retrieve Session",
                enabled: !flowController.isBusy && !pin.isEmpty
            )
        default:
            return UITableViewCell()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.section < Section.allCases.count else { return }

        switch Section(rawValue: indexPath.section) {
        case .createSession where indexPath.row == 1:
            guard !flowController.isBusy else { return }
            Task { await flowController.createSession() }
        case .retrieveSession where indexPath.row == 1:
            guard !flowController.isBusy, !pin.isEmpty else { return }
            Task { await flowController.retrieveSession(pin: pin) }
        default:
            break
        }
    }

    private func actionCell(title: String, enabled: Bool) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        var configuration = UIListContentConfiguration.cell()
        configuration.text = title
        configuration.textProperties.alignment = .center
        configuration.textProperties.color = enabled ? view.tintColor : .secondaryLabel
        cell.contentConfiguration = configuration
        cell.selectionStyle = enabled ? .default : .none
        return cell
    }

    private func bindFlowController() {
        flowController.onBusyChanged = { [weak self] _ in
            self?.tableView.reloadData()
        }
        flowController.onErrorChanged = { [weak self] _ in
            self?.tableView.reloadData()
        }
    }
}
