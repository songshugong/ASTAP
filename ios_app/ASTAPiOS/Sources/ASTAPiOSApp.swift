import UIKit
import UniformTypeIdentifiers

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UINavigationController(rootViewController: MainViewController())
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}

final class MainViewController: UIViewController, UIDocumentPickerDelegate {
    private let selectedFileLabel = UILabel()
    private let statusLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ASTAP-zh"
        view.backgroundColor = UIColor.systemBackground
        configureView()
        updateResourceStatus()
    }

    private func configureView() {
        let titleLabel = UILabel()
        titleLabel.text = "ASTAP-zh iOS Prototype"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.numberOfLines = 0

        let subtitleLabel = UILabel()
        subtitleLabel.text = "内置 iOS aarch64 命令行引擎和 W08 wide-field 星表。此版本用于验证 iOS 图形壳、资源打包和文件选择流程。"
        subtitleLabel.font = .systemFont(ofSize: 16)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0

        selectedFileLabel.text = "尚未选择 FITS 或图像文件"
        selectedFileLabel.font = .systemFont(ofSize: 15)
        selectedFileLabel.textColor = .secondaryLabel
        selectedFileLabel.numberOfLines = 0

        statusLabel.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        statusLabel.numberOfLines = 0

        let pickButton = makeButton(title: "选择 FITS / 图像文件", action: #selector(pickFile))
        let resourcesButton = makeButton(title: "查看内置星表和引擎", action: #selector(showResources))
        let solveButton = makeButton(title: "求解测试", action: #selector(runPrototypeSolve))
        let copyButton = makeButton(title: "复制 CLI 参数示例", action: #selector(copyCommandExample))

        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
            statusLabel,
            selectedFileLabel,
            pickButton,
            resourcesButton,
            solveButton,
            copyButton
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24)
        ])
    }

    private func makeButton(title: String, action: Selector) -> UIButton {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.cornerStyle = .medium
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)

        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func updateResourceStatus() {
        let databaseURL = Bundle.main.url(forResource: "w08_0101", withExtension: "001", subdirectory: "Databases")
        let engineURL = Bundle.main.url(forResource: "astap_cli", withExtension: nil, subdirectory: "Engine")

        let databaseText = databaseURL.map { "W08 星表: \($0.lastPathComponent) (\(formatSize($0)))" } ?? "W08 星表: 未找到"
        let engineText = engineURL.map { "iOS CLI 引擎: \($0.lastPathComponent) (\(formatSize($0)))" } ?? "iOS CLI 引擎: 未找到"
        statusLabel.text = "\(databaseText)\n\(engineText)"
    }

    private func formatSize(_ url: URL) -> String {
        let size = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? NSNumber)?.int64Value ?? 0
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }

    @objc private func pickFile() {
        var types: [UTType] = [.image, .data]
        if let fit = UTType(filenameExtension: "fit") {
            types.append(fit)
        }
        if let fits = UTType(filenameExtension: "fits") {
            types.append(fits)
        }

        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        picker.delegate = self
        present(picker, animated: true)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        selectedFileLabel.text = urls.first?.lastPathComponent ?? "未选择文件"
    }

    @objc private func showResources() {
        updateResourceStatus()
        showAlert(
            title: "内置资源",
            message: (statusLabel.text ?? "") + "\n\nW08 是官方 ASTAP wide-field 小星表，适合先验证 iOS 包内资源路径。"
        )
    }

    @objc private func runPrototypeSolve() {
        showAlert(
            title: "求解接口待接入",
            message: "这个 IPA 已打包 iOS CLI 引擎和 W08 星表，但 iOS App 不能直接启动包内命令行程序。下一步需要把 ASTAP 求解核心改造成同进程库接口，再由这个界面调用。"
        )
    }

    @objc private func copyCommandExample() {
        let databasePath = Bundle.main.resourcePath.map { "\($0)/Databases" } ?? "<App>/Databases"
        let command = "./astap_cli -f image.fit -r 10 -fov 1.2 -d \(databasePath) -D w08 -wcs -update -progress"
        UIPasteboard.general.string = command
        showAlert(title: "已复制", message: command)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "好", style: .default))
        present(alert, animated: true)
    }
}
