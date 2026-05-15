#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <float.h>
#import <math.h>
#import <string.h>

extern char *astap_parse_file_json(const char *inputPath, const char *databasePath);
extern char *astap_solve_file_json(const char *inputPath, const char *databasePath, const char *optionsJSON);
extern void astap_free_string(char *ptr);

static NSString *ASTAPStringFromCore(char *ptr) {
    if (ptr == NULL) {
        return @"{}";
    }
    NSString *value = [NSString stringWithUTF8String:ptr] ?: @"{}";
    astap_free_string(ptr);
    return value;
}

static NSDictionary *ASTAPJSONDictionary(NSString *json) {
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        return @{};
    }
    id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return [object isKindOfClass:NSDictionary.class] ? object : @{};
}

static NSString *ASTAPFormatSize(NSURL *url) {
    NSDictionary<NSFileAttributeKey, id> *attributes = [NSFileManager.defaultManager attributesOfItemAtPath:url.path error:nil];
    long long size = [attributes[NSFileSize] longLongValue];
    NSByteCountFormatter *formatter = [NSByteCountFormatter new];
    formatter.allowedUnits = NSByteCountFormatterUseKB | NSByteCountFormatterUseMB | NSByteCountFormatterUseGB;
    formatter.countStyle = NSByteCountFormatterCountStyleFile;
    return [formatter stringFromByteCount:size];
}

static NSString *ASTAPCardValue(NSArray<NSString *> *cards, NSString *key) {
    NSString *prefix = [key stringByPaddingToLength:8 withString:@" " startingAtIndex:0];
    for (NSString *card in cards) {
        if ([card hasPrefix:prefix] && card.length >= 10) {
            NSString *tail = [card substringFromIndex:10];
            NSRange slash = [tail rangeOfString:@"/"];
            if (slash.location != NSNotFound) {
                tail = [tail substringToIndex:slash.location];
            }
            return [tail stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
        }
    }
    return nil;
}

static uint16_t ASTAPReadBE16(const uint8_t *p) {
    return ((uint16_t)p[0] << 8) | (uint16_t)p[1];
}

static uint32_t ASTAPReadBE32(const uint8_t *p) {
    return ((uint32_t)p[0] << 24) | ((uint32_t)p[1] << 16) | ((uint32_t)p[2] << 8) | (uint32_t)p[3];
}

static uint64_t ASTAPReadBE64(const uint8_t *p) {
    return ((uint64_t)ASTAPReadBE32(p) << 32) | (uint64_t)ASTAPReadBE32(p + 4);
}

static UIImage *ASTAPRenderFITSPreview(NSURL *url) {
    NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:nil];
    if (!data || data.length < 2880) {
        return nil;
    }

    const uint8_t *bytes = data.bytes;
    NSMutableArray<NSString *> *cards = [NSMutableArray array];
    NSUInteger headerEnd = 0;
    for (NSUInteger offset = 0; offset + 80 <= data.length; offset += 80) {
        NSString *card = [[NSString alloc] initWithBytes:bytes + offset length:80 encoding:NSASCIIStringEncoding] ?: @"";
        [cards addObject:card];
        if ([card hasPrefix:@"END     "]) {
            headerEnd = offset + 80;
            break;
        }
    }
    if (headerEnd == 0) {
        return nil;
    }

    NSUInteger dataOffset = ((headerEnd + 2879) / 2880) * 2880;
    NSInteger width = ASTAPCardValue(cards, @"NAXIS1").integerValue;
    NSInteger height = ASTAPCardValue(cards, @"NAXIS2").integerValue;
    NSInteger bitpix = ASTAPCardValue(cards, @"BITPIX").integerValue;
    double bzero = ASTAPCardValue(cards, @"BZERO").doubleValue;
    double bscale = ASTAPCardValue(cards, @"BSCALE").doubleValue;
    if (bscale == 0) bscale = 1;
    if (width <= 0 || height <= 0 || dataOffset >= data.length) {
        return nil;
    }

    NSInteger bytesPerSample = labs(bitpix) / 8;
    if (bytesPerSample <= 0) {
        return nil;
    }

    NSInteger targetW = MIN(width, 640);
    NSInteger targetH = MAX(1, (NSInteger)llround((double)height * (double)targetW / (double)width));
    targetH = MIN(targetH, 640);
    NSMutableData *rgba = [NSMutableData dataWithLength:(NSUInteger)(targetW * targetH * 4)];
    uint8_t *out = rgba.mutableBytes;

    double minValue = DBL_MAX;
    double maxValue = -DBL_MAX;
    double *samples = calloc((size_t)(targetW * targetH), sizeof(double));
    if (!samples) return nil;

    for (NSInteger y = 0; y < targetH; y++) {
        NSInteger sy = MIN(height - 1, (NSInteger)floor((double)y * (double)height / (double)targetH));
        for (NSInteger x = 0; x < targetW; x++) {
            NSInteger sx = MIN(width - 1, (NSInteger)floor((double)x * (double)width / (double)targetW));
            NSUInteger pixelOffset = dataOffset + (NSUInteger)(sy * width + sx) * (NSUInteger)bytesPerSample;
            if (pixelOffset + (NSUInteger)bytesPerSample > data.length) continue;
            const uint8_t *p = bytes + pixelOffset;
            double value = 0;
            if (bitpix == 8) {
                value = p[0];
            } else if (bitpix == 16) {
                value = (int16_t)ASTAPReadBE16(p);
            } else if (bitpix == 32) {
                value = (int32_t)ASTAPReadBE32(p);
            } else if (bitpix == -32) {
                uint32_t raw = ASTAPReadBE32(p);
                float f = 0;
                memcpy(&f, &raw, sizeof(float));
                value = f;
            } else if (bitpix == -64) {
                uint64_t raw = ASTAPReadBE64(p);
                double d = 0;
                memcpy(&d, &raw, sizeof(double));
                value = d;
            }
            value = value * bscale + bzero;
            samples[y * targetW + x] = value;
            if (isfinite(value)) {
                minValue = MIN(minValue, value);
                maxValue = MAX(maxValue, value);
            }
        }
    }

    if (!isfinite(minValue) || !isfinite(maxValue) || maxValue <= minValue) {
        minValue = 0;
        maxValue = 1;
    }
    for (NSInteger i = 0; i < targetW * targetH; i++) {
        double normalized = (samples[i] - minValue) / (maxValue - minValue);
        uint8_t gray = (uint8_t)MAX(0, MIN(255, (int)llround(normalized * 255.0)));
        out[i * 4 + 0] = gray;
        out[i * 4 + 1] = gray;
        out[i * 4 + 2] = gray;
        out[i * 4 + 3] = 255;
    }
    free(samples);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)rgba);
    CGImageRef image = CGImageCreate((size_t)targetW, (size_t)targetH, 8, 32, (size_t)targetW * 4, colorSpace, kCGImageAlphaLast | kCGBitmapByteOrderDefault, provider, NULL, false, kCGRenderingIntentDefault);
    UIImage *result = image ? [UIImage imageWithCGImage:image] : nil;
    if (image) CGImageRelease(image);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    return result;
}

@interface MainViewController : UIViewController <UIDocumentPickerDelegate>
@property(nonatomic, strong) NSURL *selectedFileURL;
@property(nonatomic, strong) NSDictionary *lastResult;
@property(nonatomic, strong) UILabel *fileLabel;
@property(nonatomic, strong) UILabel *coordinateLabel;
@property(nonatomic, strong) UILabel *databaseLabel;
@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) UITextView *detailView;
@property(nonatomic, strong) UISegmentedControl *databaseControl;
@property(nonatomic, strong) UISegmentedControl *tabControl;
@property(nonatomic, strong) UITextField *fovField;
@property(nonatomic, strong) UITextField *radiusField;
@property(nonatomic, strong) UIActivityIndicatorView *spinner;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"ASTAP-zh";
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    [self configureView];
    [self refreshDatabaseStatus];
}

- (void)configureView {
    UIScrollView *scrollView = [UIScrollView new];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scrollView];
    [NSLayoutConstraint activateConstraints:@[
        [scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];

    UIStackView *root = [UIStackView new];
    root.axis = UILayoutConstraintAxisVertical;
    root.spacing = 10;
    root.translatesAutoresizingMaskIntoConstraints = NO;
    [scrollView addSubview:root];
    [NSLayoutConstraint activateConstraints:@[
        [root.leadingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.leadingAnchor constant:12],
        [root.trailingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.trailingAnchor constant:-12],
        [root.topAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.topAnchor constant:12],
        [root.bottomAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.bottomAnchor constant:-16],
        [root.widthAnchor constraintEqualToAnchor:scrollView.frameLayoutGuide.widthAnchor constant:-24]
    ]];

    UIView *topPanel = [self panelView];
    UIStackView *topStack = [self verticalStackIn:topPanel];
    self.fileLabel = [self label:@"未选择文件" font:[UIFont systemFontOfSize:14 weight:UIFontWeightSemibold] color:UIColor.labelColor];
    self.coordinateLabel = [self label:@"α --   δ --   解析后显示坐标" font:[UIFont monospacedSystemFontOfSize:14 weight:UIFontWeightRegular] color:UIColor.secondaryLabelColor];
    self.databaseLabel = [self label:@"" font:[UIFont systemFontOfSize:13] color:UIColor.secondaryLabelColor];
    [topStack addArrangedSubview:self.fileLabel];
    [topStack addArrangedSubview:self.coordinateLabel];
    [topStack addArrangedSubview:self.databaseLabel];

    UIStackView *buttonRow = [UIStackView new];
    buttonRow.axis = UILayoutConstraintAxisHorizontal;
    buttonRow.spacing = 8;
    buttonRow.distribution = UIStackViewDistributionFillEqually;
    [buttonRow addArrangedSubview:[self button:@"打开" action:@selector(pickFile)]];
    [buttonRow addArrangedSubview:[self button:@"解析" action:@selector(parseSelectedFile)]];
    [buttonRow addArrangedSubview:[self button:@"求解" action:@selector(solveSelectedFile)]];
    [topStack addArrangedSubview:buttonRow];
    [root addArrangedSubview:topPanel];

    UIView *parameterPanel = [self panelView];
    UIStackView *parameterStack = [self verticalStackIn:parameterPanel];
    self.databaseControl = [[UISegmentedControl alloc] initWithItems:@[@"auto", @"D05", @"G05"]];
    self.databaseControl.selectedSegmentIndex = 0;
    [parameterStack addArrangedSubview:self.databaseControl];
    UIStackView *fields = [UIStackView new];
    fields.axis = UILayoutConstraintAxisHorizontal;
    fields.spacing = 8;
    fields.distribution = UIStackViewDistributionFillEqually;
    self.fovField = [self textField:@"FOV 度, 0=自动" value:@"0"];
    self.radiusField = [self textField:@"半径 度" value:@"180"];
    [fields addArrangedSubview:self.fovField];
    [fields addArrangedSubview:self.radiusField];
    [parameterStack addArrangedSubview:fields];
    [root addArrangedSubview:parameterPanel];

    self.imageView = [UIImageView new];
    self.imageView.backgroundColor = UIColor.blackColor;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.layer.cornerRadius = 6;
    self.imageView.clipsToBounds = YES;
    [self.imageView.heightAnchor constraintEqualToConstant:300].active = YES;
    [root addArrangedSubview:self.imageView];

    self.tabControl = [[UISegmentedControl alloc] initWithItems:@[@"头信息", @"表格", @"参数", @"日志", @"结果"]];
    self.tabControl.selectedSegmentIndex = 0;
    [self.tabControl addTarget:self action:@selector(refreshDetailView) forControlEvents:UIControlEventValueChanged];
    [root addArrangedSubview:self.tabControl];

    self.detailView = [UITextView new];
    self.detailView.editable = NO;
    self.detailView.font = [UIFont monospacedSystemFontOfSize:12 weight:UIFontWeightRegular];
    self.detailView.layer.cornerRadius = 6;
    self.detailView.backgroundColor = UIColor.secondarySystemBackgroundColor;
    self.detailView.text = @"打开 FITS/图像文件后，这里会显示头信息、参数、日志和结果。";
    [self.detailView.heightAnchor constraintEqualToConstant:260].active = YES;
    [root addArrangedSubview:self.detailView];

    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.spinner.hidesWhenStopped = YES;
    [root addArrangedSubview:self.spinner];
}

- (UIView *)panelView {
    UIView *view = [UIView new];
    view.backgroundColor = UIColor.secondarySystemBackgroundColor;
    view.layer.cornerRadius = 6;
    return view;
}

- (UIStackView *)verticalStackIn:(UIView *)container {
    UIStackView *stack = [UIStackView new];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 8;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview:stack];
    [NSLayoutConstraint activateConstraints:@[
        [stack.leadingAnchor constraintEqualToAnchor:container.leadingAnchor constant:12],
        [stack.trailingAnchor constraintEqualToAnchor:container.trailingAnchor constant:-12],
        [stack.topAnchor constraintEqualToAnchor:container.topAnchor constant:12],
        [stack.bottomAnchor constraintEqualToAnchor:container.bottomAnchor constant:-12]
    ]];
    return stack;
}

- (UILabel *)label:(NSString *)text font:(UIFont *)font color:(UIColor *)color {
    UILabel *label = [UILabel new];
    label.text = text;
    label.font = font;
    label.textColor = color;
    label.numberOfLines = 0;
    return label;
}

- (UIButton *)button:(NSString *)title action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    UIButtonConfiguration *configuration = UIButtonConfiguration.filledButtonConfiguration;
    configuration.title = title;
    configuration.cornerStyle = UIButtonConfigurationCornerStyleMedium;
    button.configuration = configuration;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UITextField *)textField:(NSString *)placeholder value:(NSString *)value {
    UITextField *field = [UITextField new];
    field.placeholder = placeholder;
    field.text = value;
    field.borderStyle = UITextBorderStyleRoundedRect;
    field.keyboardType = UIKeyboardTypeDecimalPad;
    field.font = [UIFont systemFontOfSize:13];
    return field;
}

- (NSString *)databasePath {
    return [NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:@"Databases"];
}

- (NSString *)selectedDatabaseName {
    if (self.databaseControl.selectedSegmentIndex == 1) return @"d05";
    if (self.databaseControl.selectedSegmentIndex == 2) return @"g05";
    return @"auto";
}

- (void)refreshDatabaseStatus {
    NSURL *databaseURL = [NSURL fileURLWithPath:self.databasePath];
    NSArray<NSString *> *files = [NSFileManager.defaultManager contentsOfDirectoryAtPath:databaseURL.path error:nil] ?: @[];
    NSUInteger d05 = 0;
    NSUInteger g05 = 0;
    for (NSString *file in files) {
        if ([file hasPrefix:@"d05_"]) d05++;
        if ([file hasPrefix:@"g05_"]) g05++;
    }
    self.databaseLabel.text = [NSString stringWithFormat:@"星表路径: %@\nD05: %lu 文件   G05: %lu 文件", databaseURL.lastPathComponent, (unsigned long)d05, (unsigned long)g05];
}

- (void)pickFile {
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.data", @"public.image"] inMode:UIDocumentPickerModeImport];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    self.selectedFileURL = urls.firstObject;
    self.fileLabel.text = self.selectedFileURL ? self.selectedFileURL.lastPathComponent : @"未选择文件";
    [self updatePreview];
    [self parseSelectedFile];
}

- (void)updatePreview {
    UIImage *image = nil;
    if (self.selectedFileURL) {
        image = [UIImage imageWithContentsOfFile:self.selectedFileURL.path];
        if (!image) {
            image = ASTAPRenderFITSPreview(self.selectedFileURL);
        }
    }
    self.imageView.image = image;
}

- (void)parseSelectedFile {
    if (!self.selectedFileURL) {
        [self showAlert:@"未选择文件" message:@"请先打开 FITS 或图像文件。"];
        return;
    }
    [self.spinner startAnimating];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        char *raw = astap_parse_file_json(self.selectedFileURL.path.UTF8String, self.databasePath.UTF8String);
        NSDictionary *result = ASTAPJSONDictionary(ASTAPStringFromCore(raw));
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinner stopAnimating];
            self.lastResult = result;
            [self updateHeaderSummary];
            [self refreshDetailView];
        });
    });
}

- (void)solveSelectedFile {
    if (!self.selectedFileURL) {
        [self showAlert:@"未选择文件" message:@"请先打开 FITS 或图像文件。"];
        return;
    }
    NSDictionary *options = @{
        @"database": self.selectedDatabaseName,
        @"fovDeg": @((self.fovField.text ?: @"0").doubleValue),
        @"radiusDeg": @((self.radiusField.text ?: @"180").doubleValue),
        @"maxStars": @500,
        @"tolerance": @0.007,
        @"minStarArcsec": @1.5,
        @"downsample": @0
    };
    NSData *data = [NSJSONSerialization dataWithJSONObject:options options:0 error:nil];
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ?: @"{}";

    self.tabControl.selectedSegmentIndex = 3;
    self.detailView.text = @"正在调用 ASTAP 核心求解...";
    [self.spinner startAnimating];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        char *raw = astap_solve_file_json(self.selectedFileURL.path.UTF8String, self.databasePath.UTF8String, json.UTF8String);
        NSDictionary *result = ASTAPJSONDictionary(ASTAPStringFromCore(raw));
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinner stopAnimating];
            self.lastResult = result;
            [self updateHeaderSummary];
            [self refreshDetailView];
        });
    });
}

- (void)updateHeaderSummary {
    double ra = [self.lastResult[@"raDeg"] doubleValue];
    double dec = [self.lastResult[@"decDeg"] doubleValue];
    NSInteger width = [self.lastResult[@"imageWidth"] integerValue];
    NSInteger height = [self.lastResult[@"imageHeight"] integerValue];
    self.coordinateLabel.text = [NSString stringWithFormat:@"RA %.6f°   DEC %.6f°   %ld x %ld px", ra, dec, (long)width, (long)height];
}

- (void)refreshDetailView {
    NSInteger tab = self.tabControl.selectedSegmentIndex;
    if (!self.lastResult) {
        self.detailView.text = @"暂无解析结果。";
        return;
    }
    if (tab == 0) {
        self.detailView.text = [self joinedArray:self.lastResult[@"headerLines"]];
    } else if (tab == 1) {
        self.detailView.text = [self tableText];
    } else if (tab == 2) {
        self.detailView.text = [NSString stringWithFormat:@"数据库: %@\n星表目录: %@\nFOV: %@ 度\n搜索半径: %@ 度\n最大星数: 500\n四边形容差: 0.007\n最小星点: 1.5 arcsec", self.selectedDatabaseName, self.databasePath, self.fovField.text ?: @"0", self.radiusField.text ?: @"180"];
    } else if (tab == 3) {
        self.detailView.text = [self joinedArray:self.lastResult[@"logLines"]];
    } else {
        self.detailView.text = [NSString stringWithFormat:@"ok: %@\nsolved: %@\nerrorCode: %@\nmessage: %@\nRA: %.8f deg\nDEC: %.8f deg\nScale: %.4f arcsec/px\nRotation: %.4f deg",
                                [self.lastResult[@"ok"] boolValue] ? @"true" : @"false",
                                [self.lastResult[@"solved"] boolValue] ? @"true" : @"false",
                                self.lastResult[@"errorCode"] ?: @0,
                                self.lastResult[@"message"] ?: @"",
                                [self.lastResult[@"raDeg"] doubleValue],
                                [self.lastResult[@"decDeg"] doubleValue],
                                [self.lastResult[@"scaleArcsecPerPixel"] doubleValue],
                                [self.lastResult[@"rotationDeg"] doubleValue]];
    }
}

- (NSString *)tableText {
    NSMutableArray<NSString *> *rows = [NSMutableArray arrayWithObject:@"KEYWORD        VALUE / COMMENT"];
    for (NSString *line in self.lastResult[@"headerLines"] ?: @[]) {
        if (line.length >= 8) {
            [rows addObject:line];
        }
    }
    return [rows componentsJoinedByString:@"\n"];
}

- (NSString *)joinedArray:(id)value {
    if (![value isKindOfClass:NSArray.class]) return @"";
    return [(NSArray *)value componentsJoinedByString:@"\n"];
}

- (void)showAlert:(NSString *)title message:(NSString *)message {
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
