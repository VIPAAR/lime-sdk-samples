import UIKit
import HLSDK

final class JoinViewController: UITableViewController {
    private let flowController: DemoFlowController

    private enum Section: Int, CaseIterable {
        case session
        case localUser
        case apiKey
        case status
        case join
    }

    private enum SessionRow: Int, CaseIterable {
        case sessionID
        case pin
        case gssURL
        case sessionToken
    }

    private enum LocalUserRow: Int, CaseIterable {
        case displayName
        case avatarURL
        case camera
        case microphone
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
        title = "Join Call"
        tableView.register(FormFieldCell.self, forCellReuseIdentifier: FormFieldCell.reuseIdentifier)
        tableView.register(FormMultilineCell.self, forCellReuseIdentifier: FormMultilineCell.reuseIdentifier)
        tableView.register(FormSwitchCell.self, forCellReuseIdentifier: FormSwitchCell.reuseIdentifier)
        bindFlowController()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        var count = Section.allCases.count
        if flowController.errorMessage != nil {
            count += 1
        }
        return count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch sectionIdentifier(for: section) {
        case .session: return "Session"
        case .localUser: return "Local User"
        case .apiKey: return "API Key"
        case .status: return "Call Status"
        case .join: return nil
        default: return nil
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sectionIdentifier(for: section) {
        case .session: return SessionRow.allCases.count
        case .localUser: return LocalUserRow.allCases.count
        case .apiKey: return 1
        case .status: return flowController.callStatusMessage.isEmpty ? 0 : 1
        case .join: return 1
        case .none: return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sectionIdentifier(for: indexPath.section) {
        case .none:
            let cell = UITableViewCell(style: .default, reuseIdentifier: "ErrorCell")
            cell.selectionStyle = .none
            cell.textLabel?.text = flowController.errorMessage
            cell.textLabel?.textColor = .systemRed
            cell.textLabel?.numberOfLines = 0
            return cell
        case .session:
            return sessionCell(for: indexPath)
        case .localUser:
            return localUserCell(for: indexPath)
        case .apiKey:
            return apiKeyCell(for: indexPath)
        case .status:
            let cell = UITableViewCell(style: .default, reuseIdentifier: "StatusCell")
            cell.selectionStyle = .none
            cell.textLabel?.numberOfLines = 0
            if case .ended = flowController.callPhase {
                cell.textLabel?.textColor = .systemRed
            } else {
                cell.textLabel?.textColor = .label
            }
            cell.textLabel?.text = flowController.callStatusMessage
            return cell
        case .join:
            let cell = UITableViewCell(style: .default, reuseIdentifier: "JoinCell")
            var configuration = UIListContentConfiguration.cell()
            configuration.text = flowController.isBusy ? "Joining…" : "Join Call"
            configuration.textProperties.alignment = .center
            configuration.textProperties.color = flowController.isBusy ? .secondaryLabel : view.tintColor
            cell.contentConfiguration = configuration
            cell.selectionStyle = flowController.isBusy ? .none : .default
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard sectionIdentifier(for: indexPath.section) == .join, !flowController.isBusy else { return }
        Task { await flowController.joinCall(from: self) }
    }

    private func sectionIdentifier(for section: Int) -> Section? {
        if section < Section.allCases.count {
            return Section(rawValue: section)
        }
        return nil
    }

    private func sessionCell(for indexPath: IndexPath) -> UITableViewCell {
        guard let row = SessionRow(rawValue: indexPath.row) else { return UITableViewCell() }

        switch row {
        case .sessionToken:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FormMultilineCell.reuseIdentifier, for: indexPath) as? FormMultilineCell else {
                return UITableViewCell()
            }
            cell.configure(title: "Session Token:", text: flowController.session.sessionToken)
            cell.onTextChanged = { [weak self] text in
                self?.flowController.session.sessionToken = text
            }
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FormFieldCell.reuseIdentifier, for: indexPath) as? FormFieldCell else {
                return UITableViewCell()
            }
            switch row {
            case .sessionID:
                cell.configure(title: "Session ID:", text: flowController.session.sessionID, placeholder: "Required")
                cell.valueField.addAction(UIAction { [weak self] _ in
                    self?.flowController.session.sessionID = cell.valueField.text ?? ""
                }, for: .editingChanged)
            case .pin:
                cell.configure(title: "PIN:", text: flowController.session.sessionPIN, placeholder: "Required")
                cell.valueField.addAction(UIAction { [weak self] _ in
                    self?.flowController.session.sessionPIN = cell.valueField.text ?? ""
                }, for: .editingChanged)
            case .gssURL:
                cell.configure(title: "GSS URL:", text: flowController.session.gssServerURL, placeholder: "gss+ssl://…")
                cell.valueField.addAction(UIAction { [weak self] _ in
                    self?.flowController.session.gssServerURL = cell.valueField.text ?? ""
                }, for: .editingChanged)
            case .sessionToken:
                break
            }
            return cell
        }
    }

    private func localUserCell(for indexPath: IndexPath) -> UITableViewCell {
        guard let row = LocalUserRow(rawValue: indexPath.row) else { return UITableViewCell() }

        switch row {
        case .camera, .microphone:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FormSwitchCell.reuseIdentifier, for: indexPath) as? FormSwitchCell else {
                return UITableViewCell()
            }
            switch row {
            case .camera:
                cell.configure(title: "Camera On", isOn: flowController.session.cameraEnabled)
                cell.toggle.addAction(UIAction { [weak self] _ in
                    self?.flowController.session.cameraEnabled = cell.toggle.isOn
                }, for: .valueChanged)
            case .microphone:
                cell.configure(title: "Microphone On", isOn: flowController.session.microphoneEnabled)
                cell.toggle.addAction(UIAction { [weak self] _ in
                    self?.flowController.session.microphoneEnabled = cell.toggle.isOn
                }, for: .valueChanged)
            default:
                break
            }
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FormFieldCell.reuseIdentifier, for: indexPath) as? FormFieldCell else {
                return UITableViewCell()
            }
            switch row {
            case .displayName:
                cell.configure(title: "Display Name:", text: flowController.session.displayName, placeholder: "Required")
                cell.valueField.addAction(UIAction { [weak self] _ in
                    self?.flowController.session.displayName = cell.valueField.text ?? ""
                }, for: .editingChanged)
            case .avatarURL:
                cell.configure(title: "Avatar URL:", text: flowController.session.avatarURL, placeholder: "https://…")
                cell.valueField.addAction(UIAction { [weak self] _ in
                    self?.flowController.session.avatarURL = cell.valueField.text ?? ""
                }, for: .editingChanged)
            default:
                break
            }
            return cell
        }
    }

    private func apiKeyCell(for indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FormFieldCell.reuseIdentifier, for: indexPath) as? FormFieldCell else {
            return UITableViewCell()
        }
        cell.configure(title: "Help Lightning API Key:", text: flowController.session.apiKey, placeholder: "Required")
        cell.valueField.addAction(UIAction { [weak self] _ in
            self?.flowController.session.apiKey = cell.valueField.text ?? ""
        }, for: .editingChanged)
        return cell
    }

    private func bindFlowController() {
        flowController.onBusyChanged = { [weak self] _ in
            self?.tableView.reloadData()
        }
        flowController.onErrorChanged = { [weak self] _ in
            self?.tableView.reloadData()
        }
        flowController.onCallStatusChanged = { [weak self] _ in
            self?.tableView.reloadSections(IndexSet(integer: Section.status.rawValue), with: .automatic)
        }
        flowController.onCallPhaseChanged = { [weak self] _ in
            self?.tableView.reloadData()
        }
    }
}
