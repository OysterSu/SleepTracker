//
//  CNDetailViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/2/28.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "CNDetailViewController.h"
#import "GoogleAnalytics.h"

#import "CustomNotification-Model.h"
#import "CustomNotification.h"

@interface CNDetailViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UISwitch *switchControl;

@property (nonatomic) CustomNotification_Model *customNotificationModel;
@property (nonatomic) CustomNotification *selectedNotification;
@property (nonatomic) NSNumber *selectedRow;

@end

@implementation CNDetailViewController

- (CustomNotification_Model *)customNotificationModel
{
    if (!_customNotificationModel) {
        _customNotificationModel = [[CustomNotification_Model alloc] init];
    }
    
    return _customNotificationModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textField.text = self.selectedNotification.message;
    self.datePicker.date = self.selectedNotification.fireDate;
    self.switchControl.on = [self.selectedNotification.on boolValue];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"h:mm a"];
    self.dateLabel.text = [formatter stringFromDate:self.datePicker.date];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[[GoogleAnalytics alloc] init] trackPageView:@"Custom Notification Detail"];
}

- (IBAction)update:(id)sender
{
    [self.customNotificationModel updateRow:[self.selectedRow integerValue]
                                    message:self.textField.text
                                   fireDate:self.datePicker.date
                                         on:self.switchControl.on];
    [self.customNotificationModel resetCustomNotification];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"修改資料"
                                                    message:@"成功！"
                                                   delegate:self
                                          cancelButtonTitle:@"確定"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)valueChanged:(id)sender {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"h:mm a"];
    self.dateLabel.text = [formatter stringFromDate:self.datePicker.date];
}

#pragma mark - 把虛擬鍵盤收起來

//點擊其它地方讓鍵盤收起來
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

//按下 return 鍵收起鍵盤
- (IBAction)returnPress:(id)sender {
    [sender resignFirstResponder];
}

@end
