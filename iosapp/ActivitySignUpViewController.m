//
//  ActivitySignUpViewController.m
//  iosapp
//
//  Created by 李萍 on 15/3/3.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "ActivitySignUpViewController.h"
#import "UIView+Util.h"
#import "UIColor+Util.h"
#import "Config.h"
#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import "OSCAPI.h"
#import <Ono.h>
#import <MBProgressHUD.h>
#import "Utils.h"

#import <ReactiveCocoa.h>

@interface ActivitySignUpViewController () <UITextFieldDelegate>

@property (nonatomic, copy) UITextField *nameTextfield;
@property (nonatomic, copy) UITextField *telephoneTextfield;
@property (nonatomic, copy) UITextField *corporateNameTextfield;
@property (nonatomic, copy) UITextField *positionNameTextfield;
@property (nonatomic, copy) UISegmentedControl *sexSegmentCtl;
@property (nonatomic, copy) UIButton *saveButton;
@end

@implementation ActivitySignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"活动报名";
    
    [self setLayout];
    
    NSArray *activitySignUpInfo = [Config getActivitySignUpInfomation];
    if (activitySignUpInfo.count != 0) {
        _nameTextfield.text = activitySignUpInfo[0];
        _sexSegmentCtl.selectedSegmentIndex = [activitySignUpInfo[1] intValue];
        _telephoneTextfield.text = activitySignUpInfo[2];
        _corporateNameTextfield.text = activitySignUpInfo? activitySignUpInfo[3]: @"";
        _positionNameTextfield.text = activitySignUpInfo? activitySignUpInfo[4]: @"";
    }
    
    RACSignal *valid = [RACSignal combineLatest:@[_nameTextfield.rac_textSignal, _telephoneTextfield.rac_textSignal] reduce:^(NSString *name, NSString *telephone){
        return @(name.length > 0 && telephone.length > 0);
    }];
    RAC(_saveButton, enabled) = valid;
    RAC(_saveButton, alpha) = [valid map:^(NSNumber *b) {
        return b.boolValue ? @1 : @0.4;
    }];

}

- (void)setLayout
{
    UILabel *nameLabel = [UILabel new];
    nameLabel.text = @"姓       名＊：";
    [self.view addSubview:nameLabel];
    
    UILabel *sexLabel = [UILabel new];
    sexLabel.text = @"性       别＊：";
    [self.view addSubview:sexLabel];
    
    _sexSegmentCtl = [[UISegmentedControl alloc] initWithItems:@[@"男", @"女"]];
    _sexSegmentCtl.selectedSegmentIndex = 0;
    _sexSegmentCtl.tintColor = [UIColor colorWithHex:0x15A230];
    [self.view addSubview:_sexSegmentCtl];
    
    UILabel *telephoneLabel = [UILabel new];
    telephoneLabel.text = @"电话号码＊：";
    [self.view addSubview:telephoneLabel];
    
    UILabel *corporateNameLabel = [UILabel new];
    corporateNameLabel.text = @"单位名称：";
    [self.view addSubview:corporateNameLabel];
    
    UILabel *positionNameLabel = [UILabel new];
    positionNameLabel.text = @"职位名称：";
    [self.view addSubview:positionNameLabel];
    
    
    _nameTextfield = [UITextField new];
    _nameTextfield.placeholder = @" 请输入姓名（必填）";
    _nameTextfield.delegate = self;
    //[_nameTextfield setBorderWidth:1 andColor:[UIColor grayColor]];
    _nameTextfield.borderStyle = UITextBorderStyleRoundedRect;
    //[_nameTextfield setCornerRadius:5.0];
    _nameTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    [self.view addSubview:_nameTextfield];
    
    _telephoneTextfield = [UITextField new];
    _telephoneTextfield.placeholder = @"请输入电话号码（必填）";
    _telephoneTextfield.delegate = self;
    _telephoneTextfield.borderStyle = UITextBorderStyleRoundedRect;
    _telephoneTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:_telephoneTextfield];
    
    _corporateNameTextfield = [UITextField new];
    _corporateNameTextfield.placeholder = @"请输入单位名称";
    _corporateNameTextfield.delegate = self;
    _corporateNameTextfield.borderStyle = UITextBorderStyleRoundedRect;
    _corporateNameTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:_corporateNameTextfield];
    
    _positionNameTextfield = [UITextField new];
    _positionNameTextfield.placeholder = @"请输入职位名称";
    _positionNameTextfield.delegate = self;
    _positionNameTextfield.borderStyle = UITextBorderStyleRoundedRect;
    _positionNameTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:_positionNameTextfield];
    
    _saveButton = [UIButton new];
    _saveButton.backgroundColor = [UIColor redColor];
    [_saveButton setCornerRadius:5.0];
    [_saveButton setTitle:@"确定" forState:UIControlStateNormal];
    [self.view addSubview:_saveButton];
    _saveButton.userInteractionEnabled = YES;
    
    [_saveButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enterActivity)]];
    
    for (UIView *subView in [self.view subviews]) {
        subView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
#if 0
    
    NSDictionary *viewDic = NSDictionaryOfVariableBindings(nameLabel, _nameTextfield, sexLabel, _sexSegmentCtl, telephoneLabel, _telephoneTextfield, corporateNameLabel, _corporateNameTextfield, positionNameLabel, _positionNameTextfield, saveButton);

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-75-[nameLabel]-5-[_nameTextfield(fieldHeight)]-10-[sexLabel]-10-[telephoneLabel]-5-[_telephoneTextfield(fieldHeight)]-10-[corporateNameLabel]-5-[_corporateNameTextfield(fieldHeight)]-10-[positionNameLabel]-5-[_positionNameTextfield(fieldHeight)]-25-[_saveButton]" options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight metrics:@{@"fieldHeight": @(30)} views:viewDic]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[nameLabel]-10-|" options:0 metrics:nil views:viewDic]];
    
#else
    
    NSDictionary *viewDic = NSDictionaryOfVariableBindings(_nameTextfield, sexLabel, _sexSegmentCtl, _telephoneTextfield, _corporateNameTextfield, _positionNameTextfield, _saveButton);

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-75-[_nameTextfield(fieldHeight)]-12-[sexLabel]-15-[_telephoneTextfield(fieldHeight)]-15-[_corporateNameTextfield(fieldHeight)]-15-[_positionNameTextfield(fieldHeight)]-25-[_saveButton]" options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight metrics:@{@"fieldHeight": @(30)} views:viewDic]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[_nameTextfield]-10-|" options:0 metrics:nil views:viewDic]];
    
#endif
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:sexLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual
                                                             toItem:_sexSegmentCtl attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:sexLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
                                                             toItem:_sexSegmentCtl attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_sexSegmentCtl(100)]" options:0 metrics:nil views:viewDic]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [textField resignFirstResponder];
    return YES;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_nameTextfield resignFirstResponder];
    [_telephoneTextfield resignFirstResponder];
    [_corporateNameTextfield resignFirstResponder];
    [_positionNameTextfield resignFirstResponder];
}


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.view.frame.size.height < 568) {
        float y = self.view.frame.origin.y;
        float width = self.view.frame.size.width;
        float height = self.view.frame.size.height;
        
        if (textField == _corporateNameTextfield || textField == _positionNameTextfield) {
            CGRect rect = CGRectMake(0.0f, y-100, width, height);
            self.view.frame = rect;
        }
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (self.view.frame.size.height < 568) {
        float y = self.view.frame.origin.y;
        float width = self.view.frame.size.width;
        float height = self.view.frame.size.height;
        
        if (textField == _corporateNameTextfield || textField == _positionNameTextfield){
            CGRect rect = CGRectMake(0.0f, y+100, width, height);
            self.view.frame = rect;
        }
    }
    return YES;
}


//保存报名信息
- (void)enterActivity
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFOnoResponseSerializer XMLResponseSerializer];
    [manager POST:[NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_EVENT_APPLY]
       parameters:@{
                    @"event":@(_eventId),
                    @"user": @([Config getOwnID]),
                    @"name":_nameTextfield.text,
                    @"gender":@(_sexSegmentCtl.selectedSegmentIndex) ,
                    @"mobile":_telephoneTextfield.text,
                    @"company":_corporateNameTextfield.text,
                    @"job":_positionNameTextfield.text
                    }
          success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
              ONOXMLElement *result = [responseObject.rootElement firstChildWithTag:@"result"];
              
              NSInteger errorCode = [[[result firstChildWithTag:@"errorCode"] numberValue] integerValue];
              NSString *errorMessage = [[result firstChildWithTag:@"errormessage"] stringValue];
              
              MBProgressHUD *HUD = [Utils createHUDInWindowOfView:self.view];
              HUD.mode = MBProgressHUDModeCustomView;
              
              if (errorCode == 1) {
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                  HUD.labelText = [NSString stringWithFormat:@"%@", errorMessage];
              } else {
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  HUD.labelText = [NSString stringWithFormat:@"错误：%@", errorMessage];
              }
              
              [HUD hide:YES afterDelay:2];
              
              [Config saveActivityActorName:_nameTextfield.text
                                     andSex:_sexSegmentCtl.selectedSegmentIndex
                         andTelephoneNumber:_telephoneTextfield.text
                           andCorporateName:_corporateNameTextfield.text
                            andPositionName:_positionNameTextfield.text];
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"网络异常，错误码：%ld", (long)error.code);
          }
     ];
    
}


@end
