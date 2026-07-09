#import "JoinViewController.h"
#import "DemoFlowController.h"
#import "FormFieldCell.h"

typedef NS_ENUM(NSInteger, JoinSection) {
    JoinSectionSession = 0,
    JoinSectionLocalUser = 1,
    JoinSectionAPIKey = 2,
    JoinSectionStatus = 3,
    JoinSectionJoin = 4,
    JoinSectionCount = 5
};

@interface JoinViewController ()
@property (nonatomic, weak) DemoFlowController *flowController;
@end

@implementation JoinViewController

- (instancetype)initWithFlowController:(DemoFlowController *)flowController {
    self = [super initWithStyle:UITableViewStyleInsetGrouped];
    if (self) {
        _flowController = flowController;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Join Call";
    [self.tableView registerClass:[FormFieldCell class] forCellReuseIdentifier:FormFieldCell.reuseIdentifier];
    [self.tableView registerClass:[FormMultilineCell class] forCellReuseIdentifier:FormMultilineCell.reuseIdentifier];
    [self.tableView registerClass:[FormSwitchCell class] forCellReuseIdentifier:FormSwitchCell.reuseIdentifier];
    [self bindFlowController];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.flowController.errorMessage == nil ? JoinSectionCount : JoinSectionCount + 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section >= JoinSectionCount) { return nil; }
    switch (section) {
        case JoinSectionSession: return @"Session";
        case JoinSectionLocalUser: return @"Local User";
        case JoinSectionAPIKey: return @"API Key";
        case JoinSectionStatus: return @"Call Status";
        default: return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == JoinSectionCount) { return 1; }
    if (section == JoinSectionStatus) {
        return self.flowController.callStatusMessage.length > 0 ? 1 : 0;
    }
    switch (section) {
        case JoinSectionSession: return 4;
        case JoinSectionLocalUser: return 4;
        case JoinSectionAPIKey: return 1;
        case JoinSectionJoin: return 1;
        default: return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == JoinSectionCount) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ErrorCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ErrorCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.numberOfLines = 0;
        }
        cell.textLabel.text = self.flowController.errorMessage;
        cell.textLabel.textColor = UIColor.systemRedColor;
        return cell;
    }

    DemoSession *session = self.flowController.session;

    if (indexPath.section == JoinSectionSession) {
        if (indexPath.row == 3) {
            FormMultilineCell *cell = [tableView dequeueReusableCellWithIdentifier:FormMultilineCell.reuseIdentifier forIndexPath:indexPath];
            [cell configureWithTitle:@"Session Token:" text:session.sessionToken];
            __weak DemoSession *weakSession = session;
            cell.onTextChanged = ^(NSString *text) {
                weakSession.sessionToken = text ?: @"";
            };
            return cell;
        }
        FormFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:FormFieldCell.reuseIdentifier forIndexPath:indexPath];
        switch (indexPath.row) {
            case 0:
                [cell configureWithTitle:@"Session ID:" text:session.sessionID placeholder:@"Required" keyboardType:UIKeyboardTypeDefault];
                [cell.valueField addTarget:self action:@selector(sessionIDChanged:) forControlEvents:UIControlEventEditingChanged];
                break;
            case 1:
                [cell configureWithTitle:@"PIN:" text:session.sessionPIN placeholder:@"Required" keyboardType:UIKeyboardTypeDefault];
                [cell.valueField addTarget:self action:@selector(sessionPINChanged:) forControlEvents:UIControlEventEditingChanged];
                break;
            case 2:
                [cell configureWithTitle:@"GSS URL:" text:session.gssServerURL placeholder:@"gss+ssl://…" keyboardType:UIKeyboardTypeURL];
                [cell.valueField addTarget:self action:@selector(gssURLChanged:) forControlEvents:UIControlEventEditingChanged];
                break;
            default:
                break;
        }
        return cell;
    }

    if (indexPath.section == JoinSectionLocalUser) {
        if (indexPath.row == 2 || indexPath.row == 3) {
            FormSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:FormSwitchCell.reuseIdentifier forIndexPath:indexPath];
            if (indexPath.row == 2) {
                [cell configureWithTitle:@"Camera On" isOn:session.cameraEnabled];
                [cell.toggle addTarget:self action:@selector(cameraChanged:) forControlEvents:UIControlEventValueChanged];
            } else {
                [cell configureWithTitle:@"Microphone On" isOn:session.microphoneEnabled];
                [cell.toggle addTarget:self action:@selector(microphoneChanged:) forControlEvents:UIControlEventValueChanged];
            }
            return cell;
        }
        FormFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:FormFieldCell.reuseIdentifier forIndexPath:indexPath];
        if (indexPath.row == 0) {
            [cell configureWithTitle:@"Display Name:" text:session.displayName placeholder:@"Required" keyboardType:UIKeyboardTypeDefault];
            [cell.valueField addTarget:self action:@selector(displayNameChanged:) forControlEvents:UIControlEventEditingChanged];
        } else {
            [cell configureWithTitle:@"Avatar URL:" text:session.avatarURL placeholder:@"https://…" keyboardType:UIKeyboardTypeURL];
            [cell.valueField addTarget:self action:@selector(avatarURLChanged:) forControlEvents:UIControlEventEditingChanged];
        }
        return cell;
    }

    if (indexPath.section == JoinSectionAPIKey) {
        FormFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:FormFieldCell.reuseIdentifier forIndexPath:indexPath];
        [cell configureWithTitle:@"Help Lightning API Key:" text:session.apiKey placeholder:@"Required" keyboardType:UIKeyboardTypeDefault];
        [cell.valueField addTarget:self action:@selector(apiKeyChanged:) forControlEvents:UIControlEventEditingChanged];
        return cell;
    }

    if (indexPath.section == JoinSectionStatus) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StatusCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"StatusCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.numberOfLines = 0;
        }
        cell.textLabel.text = self.flowController.callStatusMessage;
        cell.textLabel.textColor = self.flowController.callPhase == DemoCallPhaseEnded
            ? UIColor.systemRedColor
            : UIColor.labelColor;
        return cell;
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JoinCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"JoinCell"];
    }
    UIListContentConfiguration *configuration = [UIListContentConfiguration cellConfiguration];
    configuration.text = self.flowController.isBusy ? @"Joining…" : @"Join Call";
    configuration.textProperties.alignment = NSTextAlignmentCenter;
    configuration.textProperties.color = self.flowController.isBusy ? UIColor.secondaryLabelColor : self.view.tintColor;
    cell.contentConfiguration = configuration;
    cell.selectionStyle = self.flowController.isBusy ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == JoinSectionJoin && !self.flowController.isBusy) {
        [self.flowController joinCallFromViewController:self];
    }
}

- (void)sessionIDChanged:(UITextField *)field { self.flowController.session.sessionID = field.text ?: @""; }
- (void)sessionPINChanged:(UITextField *)field { self.flowController.session.sessionPIN = field.text ?: @""; }
- (void)gssURLChanged:(UITextField *)field { self.flowController.session.gssServerURL = field.text ?: @""; }
- (void)displayNameChanged:(UITextField *)field { self.flowController.session.displayName = field.text ?: @""; }
- (void)avatarURLChanged:(UITextField *)field { self.flowController.session.avatarURL = field.text ?: @""; }
- (void)apiKeyChanged:(UITextField *)field { self.flowController.session.apiKey = field.text ?: @""; }
- (void)cameraChanged:(UISwitch *)toggle { self.flowController.session.cameraEnabled = toggle.isOn; }
- (void)microphoneChanged:(UISwitch *)toggle { self.flowController.session.microphoneEnabled = toggle.isOn; }

- (void)bindFlowController {
    __weak typeof(self) weakSelf = self;
    self.flowController.onBusyChanged = ^(BOOL busy) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        (void)busy;
        [strongSelf.tableView reloadData];
    };
    self.flowController.onErrorChanged = ^(NSString * _Nullable errorMessage) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        (void)errorMessage;
        [strongSelf.tableView reloadData];
    };
    self.flowController.onCallStatusChanged = ^(NSString *message) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        (void)message;
        [strongSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:JoinSectionStatus]
                            withRowAnimation:UITableViewRowAnimationAutomatic];
    };
    self.flowController.onCallPhaseChanged = ^(DemoCallPhase phase) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        (void)phase;
        [strongSelf.tableView reloadData];
    };
}

@end
