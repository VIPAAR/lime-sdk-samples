#import "FormFieldCell.h"

@implementation FormFieldCell

+ (NSString *)reuseIdentifier {
    return @"FormFieldCell";
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        [_titleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

        _valueField = [[UITextField alloc] init];
        _valueField.borderStyle = UITextBorderStyleNone;
        _valueField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _valueField.textAlignment = NSTextAlignmentRight;

        UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[_titleLabel, _valueField]];
        stack.axis = UILayoutConstraintAxisHorizontal;
        stack.spacing = 12;
        stack.alignment = UIStackViewAlignmentCenter;
        stack.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:stack];

        UILayoutGuide *margins = self.contentView.layoutMarginsGuide;
        [NSLayoutConstraint activateConstraints:@[
            [stack.leadingAnchor constraintEqualToAnchor:margins.leadingAnchor],
            [stack.trailingAnchor constraintEqualToAnchor:margins.trailingAnchor],
            [stack.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:10],
            [stack.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-10]
        ]];
    }
    return self;
}

- (void)configureWithTitle:(NSString *)title
                      text:(NSString *)text
               placeholder:(NSString *)placeholder
              keyboardType:(UIKeyboardType)keyboardType {
    self.titleLabel.text = title;
    self.valueField.text = text.length > 0 ? text : @"";
    self.valueField.placeholder = placeholder;
    self.valueField.keyboardType = keyboardType;
    self.valueField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.valueField.autocorrectionType = UITextAutocorrectionTypeNo;
}

@end

@implementation FormMultilineCell

+ (NSString *)reuseIdentifier {
    return @"FormMultilineCell";
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];

        _valueView = [[UITextView alloc] init];
        _valueView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _valueView.scrollEnabled = NO;
        _valueView.delegate = self;
        _valueView.backgroundColor = UIColor.clearColor;

        UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[_titleLabel, _valueView]];
        stack.axis = UILayoutConstraintAxisVertical;
        stack.spacing = 8;
        stack.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:stack];

        UILayoutGuide *margins = self.contentView.layoutMarginsGuide;
        [NSLayoutConstraint activateConstraints:@[
            [stack.leadingAnchor constraintEqualToAnchor:margins.leadingAnchor],
            [stack.trailingAnchor constraintEqualToAnchor:margins.trailingAnchor],
            [stack.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:10],
            [stack.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-10],
            [_valueView.heightAnchor constraintGreaterThanOrEqualToConstant:80]
        ]];
    }
    return self;
}

- (void)configureWithTitle:(NSString *)title text:(NSString *)text {
    self.titleLabel.text = title;
    self.valueView.text = text;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (self.onTextChanged) {
        self.onTextChanged(textView.text ?: @"");
    }
}

@end

@implementation FormSwitchCell

+ (NSString *)reuseIdentifier {
    return @"FormSwitchCell";
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _toggle = [[UISwitch alloc] init];

        UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[_titleLabel, _toggle]];
        stack.axis = UILayoutConstraintAxisHorizontal;
        stack.spacing = 12;
        stack.alignment = UIStackViewAlignmentCenter;
        stack.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:stack];

        UILayoutGuide *margins = self.contentView.layoutMarginsGuide;
        [NSLayoutConstraint activateConstraints:@[
            [stack.leadingAnchor constraintEqualToAnchor:margins.leadingAnchor],
            [stack.trailingAnchor constraintEqualToAnchor:margins.trailingAnchor],
            [stack.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:10],
            [stack.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-10]
        ]];
    }
    return self;
}

- (void)configureWithTitle:(NSString *)title isOn:(BOOL)isOn {
    self.titleLabel.text = title;
    self.toggle.on = isOn;
}

@end
