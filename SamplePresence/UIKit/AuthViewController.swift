import UIKit

final class AuthViewController: UITableViewController {
    private let flowController: DemoFlowController

    private enum Row: Int, CaseIterable {
        case serverURL
        case userEmail
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
        title = "Authenticate"
        tableView.register(FormFieldCell.self, forCellReuseIdentifier: FormFieldCell.reuseIdentifier)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Authenticate",
            style: .done,
            target: self,
            action: #selector(authenticateTapped)
        )
        bindFlowController()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        flowController.errorMessage == nil ? 1 : 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return Row.allCases.count
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "ErrorCell")
            cell.selectionStyle = .none
            cell.textLabel?.text = flowController.errorMessage
            cell.textLabel?.textColor = .systemRed
            cell.textLabel?.numberOfLines = 0
            return cell
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: FormFieldCell.reuseIdentifier, for: indexPath) as? FormFieldCell,
              let row = Row(rawValue: indexPath.row) else {
            return UITableViewCell()
        }

        switch row {
        case .serverURL:
            cell.configure(
                title: "Server URL:",
                text: flowController.session.serverURL,
                placeholder: "http://127.0.0.1:8777"
            )
            cell.valueField.addAction(UIAction { [weak self] _ in
                self?.flowController.session.serverURL = cell.valueField.text ?? ""
            }, for: .editingChanged)
        case .userEmail:
            cell.configure(
                title: "User Email:",
                text: flowController.session.userEmail,
                placeholder: "user@example.com",
                keyboardType: .emailAddress
            )
            cell.valueField.addAction(UIAction { [weak self] _ in
                self?.flowController.session.userEmail = cell.valueField.text ?? ""
            }, for: .editingChanged)
        }

        return cell
    }

    @objc
    private func authenticateTapped() {
        view.endEditing(true)
        Task { await flowController.authenticate() }
    }

    private func bindFlowController() {
        flowController.onBusyChanged = { [weak self] isBusy in
            self?.navigationItem.rightBarButtonItem?.isEnabled = !isBusy
            self?.navigationItem.rightBarButtonItem?.title = isBusy ? "Authenticating…" : "Authenticate"
        }
        flowController.onErrorChanged = { [weak self] _ in
            self?.tableView.reloadData()
        }
    }
}
