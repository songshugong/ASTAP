#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController <UIDocumentPickerDelegate>
@property(nonatomic, strong) UILabel *statusLabel;
@property(nonatomic, strong) UILabel *selectedFileLabel;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"ASTAP-zh";
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    [self configureView];
    [self updateResourceStatus];
}

- (void)configureView {
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = @"ASTAP-zh iOS Prototype";
    titleLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
    titleLabel.numberOfLines = 0;

    UILabel *subtitleLabel = [UILabel new];
    subtitleLabel.text = @"内置 iOS aarch64 命令行引擎和 W08 wide-field 星表。此版本用于验证 iOS 图形壳、资源打包和文件选择流程。";
    subtitleLabel.font = [UIFont systemFontOfSize:16];
    subtitleLabel.textColor = UIColor.secondaryLabelColor;
    subtitleLabel.numberOfLines = 0;

    self.statusLabel = [UILabel new];
    self.statusLabel.font = [UIFont monospacedSystemFontOfSize:13 weight:UIFontWeightRegular];
    self.statusLabel.numberOfLines = 0;

    self.selectedFileLabel = [UILabel new];
    self.selectedFileLabel.text = @"尚未选择 FITS 或图像文件";
    self.selectedFileLabel.font = [UIFont systemFontOfSize:15];
    self.selectedFileLabel.textColor = UIColor.secondaryLabelColor;
    self.selectedFileLabel.numberOfLines = 0;

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[
        titleLabel,
        subtitleLabel,
        self.statusLabel,
        self.selectedFileLabel,
        [self buttonWithTitle:@"选择 FITS / 图像文件" action:@selector(pickFile)],
        [self buttonWithTitle:@"查看内置星表和引擎" action:@selector(showResources)],
        [self buttonWithTitle:@"求解测试" action:@selector(runPrototypeSolve)],
        [self buttonWithTitle:@"复制 CLI 参数示例" action:@selector(copyCommandExample)]
    ]];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 16;
    stack.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:stack];
    [NSLayoutConstraint activateConstraints:@[
        [stack.leadingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.leadingAnchor],
        [stack.trailingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.trailingAnchor],
        [stack.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:24]
    ]];
}

- (UIButton *)buttonWithTitle:(NSString *)title action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    if (@available(iOS 15.0, *)) {
        UIButtonConfiguration *configuration = UIButtonConfiguration.filledButtonConfiguration;
        configuration.title = title;
        configuration.cornerStyle = UIButtonConfigurationCornerStyleMedium;
        configuration.contentInsets = NSDirectionalEdgeInsetsMake(14, 16, 14, 16);
        button.configuration = configuration;
    } else {
        [button setTitle:title forState:UIControlStateNormal];
        button.contentEdgeInsets = UIEdgeInsetsMake(14, 16, 14, 16);
        button.backgroundColor = self.view.tintColor;
        [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        button.layer.cornerRadius = 8;
    }
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)updateResourceStatus {
    NSURL *databaseURL = [NSBundle.mainBundle URLForResource:@"w08_0101" withExtension:@"001" subdirectory:@"Databases"];
    NSURL *engineURL = [NSBundle.mainBundle URLForResource:@"astap_cli" withExtension:nil subdirectory:@"Engine"];

    NSString *databaseText = databaseURL ? [NSString stringWithFormat:@"W08 星表: %@ (%@)", databaseURL.lastPathComponent, [self formatSize:databaseURL]] : @"W08 星表: 未找到";
    NSString *engineText = engineURL ? [NSString stringWithFormat:@"iOS CLI 引擎: %@ (%@)", engineURL.lastPathComponent, [self formatSize:engineURL]] : @"iOS CLI 引擎: 未找到";
    self.statusLabel.text = [NSString stringWithFormat:@"%@\n%@", databaseText, engineText];
}

- (NSString *)formatSize:(NSURL *)url {
    NSDictionary<NSFileAttributeKey, id> *attributes = [NSFileManager.defaultManager attributesOfItemAtPath:url.path error:nil];
    long long size = [attributes[NSFileSize] longLongValue];
    NSByteCountFormatter *formatter = [NSByteCountFormatter new];
    formatter.allowedUnits = NSByteCountFormatterUseKB | NSByteCountFormatterUseMB;
    formatter.countStyle = NSByteCountFormatterCountStyleFile;
    return [formatter stringFromByteCount:size];
}

- (void)pickFile {
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.data", @"public.image"] inMode:UIDocumentPickerModeImport];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    NSURL *url = urls.firstObject;
    self.selectedFileLabel.text = url ? url.lastPathComponent : @"未选择文件";
}

- (void)showResources {
    [self updateResourceStatus];
    NSString *message = [NSString stringWithFormat:@"%@\n\nW08 是官方 ASTAP wide-field 小星表，适合先验证 iOS 包内资源路径。", self.statusLabel.text ?: @""];
    [self showAlertWithTitle:@"内置资源" message:message];
}

- (void)runPrototypeSolve {
    [self showAlertWithTitle:@"求解接口待接入" message:@"这个 IPA 已打包 iOS CLI 引擎和 W08 星表，但 iOS App 不能直接启动包内命令行程序。下一步需要把 ASTAP 求解核心改造成同进程库接口，再由这个界面调用。"];
}

- (void)copyCommandExample {
    NSString *resourcePath = NSBundle.mainBundle.resourcePath ?: @"<App>";
    NSString *command = [NSString stringWithFormat:@"./astap_cli -f image.fit -r 10 -fov 1.2 -d %@/Databases -D w08 -wcs -update -progress", resourcePath];
    UIPasteboard.generalPasteboard.string = command;
    [self showAlertWithTitle:@"已复制" message:command];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property(nonatomic, strong) UIWindow *window;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    MainViewController *mainViewController = [MainViewController new];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end

int main(int argc, char *argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass(AppDelegate.class));
    }
}
