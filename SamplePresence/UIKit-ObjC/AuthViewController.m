#import "AuthViewController.h"
#import "DemoFlowController.h"
#import "FormFieldCell.h"

typedef NS_ENUM(NSInteger, AuthRow) {
    AuthRowServerURL = 0,
    AuthRowUserEmail = 1,
    AuthRowCount = 2
};

@interface AuthViewController ()
@property (nonatomic, weak) DemoFlowController *flowController;
@end

@implementation AuthViewController

- (instancetype)initWithFlowController:(DemoFlowController *)flowController {
    self = [super initWithStyle:UITableViewStyleInsetGrouped];
    if (self) {
        _flowController = flowController;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Authenticate";
    [self.tableView registerClass:[FormFieldCell class] forCellReuseIdentifier:FormFieldCell.reuseIdentifier];
    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Authenticate"
                                         style:UIBarButtonItemStyleDone
                                        target:self
                                        action:@selector(authenticateTapped)];
    [self bindFlowController];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.flowController.errorMessage == nil ? 1 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? AuthRowCount : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
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

    FormFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:FormFieldCell.reuseIdentifier forIndexPath:indexPath];
    DemoSession *session = self.flowController.session;
    __weak typeof(self) weakSelf = self;

    if (indexPath.row == AuthRowServerURL) {
        [cell configureWithTitle:@"Server URL:"
                            text:session.serverURL
                     placeholder:@"http://127.0.0.1:8777"
                    keyboardType:UIKeyboardTypeURL];
        [cell.valueField addTarget:self action:@selector(serverURLChanged:) forControlEvents:UIControlEventEditingChanged];
    } else {
        [cell configureWithTitle:@"User Email:"
                            text:session.userEmail
                     placeholder:@"user@example.com"
                    keyboardType:UIKeyboardTypeEmailAddress];
        [cell.valueField addTarget:self action:@selector(userEmailChanged:) forControlEvents:UIControlEventEditingChanged];
    }

    (void)weakSelf;
    return cell;
}

- (void)serverURLChanged:(UITextField *)field {
    self.flowController.session.serverURL = field.text ?: @"";
}

- (void)userEmailChanged:(UITextField *)field {
    self.flowController.session.userEmail = field.text ?: @"";
}

- (void)authenticateTapped {
    [self.view endEditing:YES];
    [self.flowController authenticate];
}

- (void)bindFlowController {
    __weak typeof(self) weakSelf = self;
    self.flowController.onBusyChanged = ^(BOOL busy) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        strongSelf.navigationItem.rightBarButtonItem.enabled = !busy;
        strongSelf.navigationItem.rightBarButtonItem.title = busy ? @"Authenticating…" : @"Authenticate";
    };
    self.flowController.onErrorChanged = ^(NSString * _Nullable errorMessage) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        (void)errorMessage;
        [strongSelf.tableView reloadData];
    };
}

@end
