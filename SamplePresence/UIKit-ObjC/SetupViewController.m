#import "SetupViewController.h"
#import "DemoFlowController.h"
#import "FormFieldCell.h"

typedef NS_ENUM(NSInteger, SetupSection) {
    SetupSectionAuthToken = 0,
    SetupSectionCreateSession = 1,
    SetupSectionRetrieveSession = 2,
    SetupSectionCount = 3
};

@interface SetupViewController ()
@property (nonatomic, weak) DemoFlowController *flowController;
@property (nonatomic, copy) NSString *pin;
@end

@implementation SetupViewController

- (instancetype)initWithFlowController:(DemoFlowController *)flowController {
    self = [super initWithStyle:UITableViewStyleInsetGrouped];
    if (self) {
        _flowController = flowController;
        _pin = @"";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Setup Session";
    [self.tableView registerClass:[FormFieldCell class] forCellReuseIdentifier:FormFieldCell.reuseIdentifier];
    [self bindFlowController];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.flowController.errorMessage == nil ? SetupSectionCount : SetupSectionCount + 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case SetupSectionAuthToken: return @"Auth Token";
        case SetupSectionCreateSession: return @"Create Session";
        case SetupSectionRetrieveSession: return @"Retrieve Session";
        default: return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == SetupSectionCount) {
        return 1;
    }
    switch (section) {
        case SetupSectionAuthToken: return 1;
        case SetupSectionCreateSession: return 2;
        case SetupSectionRetrieveSession: return 2;
        default: return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SetupSectionCount) {
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

    if (indexPath.section == SetupSectionAuthToken) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TokenCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TokenCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
            cell.textLabel.numberOfLines = 0;
        }
        cell.textLabel.text = self.flowController.session.authToken;
        return cell;
    }

    if (indexPath.section == SetupSectionCreateSession) {
        if (indexPath.row == 0) {
            FormFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:FormFieldCell.reuseIdentifier forIndexPath:indexPath];
            [cell configureWithTitle:@"Contact Email:"
                                text:self.flowController.session.contactEmail
                         placeholder:@"contact@example.com"
                        keyboardType:UIKeyboardTypeEmailAddress];
            [cell.valueField addTarget:self action:@selector(contactEmailChanged:) forControlEvents:UIControlEventEditingChanged];
            return cell;
        }
        return [self actionCellWithTitle:self.flowController.isBusy ? @"Creating…" : @"Create Session"
                                 enabled:!self.flowController.isBusy];
    }

    if (indexPath.row == 0) {
        FormFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:FormFieldCell.reuseIdentifier forIndexPath:indexPath];
        [cell configureWithTitle:@"PIN:" text:self.pin placeholder:@"Required" keyboardType:UIKeyboardTypeDefault];
        [cell.valueField addTarget:self action:@selector(pinChanged:) forControlEvents:UIControlEventEditingChanged];
        return cell;
    }

    BOOL enabled = !self.flowController.isBusy && self.pin.length > 0;
    return [self actionCellWithTitle:self.flowController.isBusy ? @"Retrieving…" : @"Retrieve Session"
                             enabled:enabled];
}

- (UITableViewCell *)actionCellWithTitle:(NSString *)title enabled:(BOOL)enabled {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    UIListContentConfiguration *configuration = [UIListContentConfiguration cellConfiguration];
    configuration.text = title;
    configuration.textProperties.alignment = NSTextAlignmentCenter;
    configuration.textProperties.color = enabled ? self.view.tintColor : UIColor.secondaryLabelColor;
    cell.contentConfiguration = configuration;
    cell.selectionStyle = enabled ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section >= SetupSectionCount) { return; }

    if (indexPath.section == SetupSectionCreateSession && indexPath.row == 1 && !self.flowController.isBusy) {
        [self.flowController createSession];
    } else if (indexPath.section == SetupSectionRetrieveSession && indexPath.row == 1
               && !self.flowController.isBusy && self.pin.length > 0) {
        [self.flowController retrieveSessionWithPIN:self.pin];
    }
}

- (void)contactEmailChanged:(UITextField *)field {
    self.flowController.session.contactEmail = field.text ?: @"";
}

- (void)pinChanged:(UITextField *)field {
    self.pin = field.text ?: @"";
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SetupSectionRetrieveSession]
                  withRowAnimation:UITableViewRowAnimationNone];
}

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
}

@end
