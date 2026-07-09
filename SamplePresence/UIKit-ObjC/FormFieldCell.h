#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FormFieldCell : UITableViewCell
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UITextField *valueField;
+ (NSString *)reuseIdentifier;
- (void)configureWithTitle:(NSString *)title
                      text:(NSString *)text
               placeholder:(NSString *)placeholder
              keyboardType:(UIKeyboardType)keyboardType;
@end

@interface FormMultilineCell : UITableViewCell <UITextViewDelegate>
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UITextView *valueView;
@property (nonatomic, copy, nullable) void (^onTextChanged)(NSString *text);
+ (NSString *)reuseIdentifier;
- (void)configureWithTitle:(NSString *)title text:(NSString *)text;
@end

@interface FormSwitchCell : UITableViewCell
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UISwitch *toggle;
+ (NSString *)reuseIdentifier;
- (void)configureWithTitle:(NSString *)title isOn:(BOOL)isOn;
@end

NS_ASSUME_NONNULL_END
