//
//  CustomeNotificationOneTableViewController.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/1/22.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "CustomeNotificationOneTableViewController.h"
#import "GoogleAnalytics.h"

#import "CustomNotification-Model.h"
#import "CustomNotification.h"

#import "CustomNotificationTableViewCell.h"

@interface CustomeNotificationOneTableViewController ()

@property (strong, nonatomic) NSArray *fetchDataArray;

@property (strong, nonatomic) CustomNotification_Model *customNotificationModel;
@property (strong, nonatomic) CustomNotification *customNotification;

@end

@implementation CustomeNotificationOneTableViewController

@synthesize fetchDataArray;

- (CustomNotification_Model *)customNotificationModel
{
    if (!_customNotificationModel) {
        _customNotificationModel = [[CustomNotification_Model alloc] init];
    }
    
    return _customNotificationModel;
}

- (CustomNotification *)customNotification
{
    if (!_customNotification) {
        _customNotification = [[CustomNotification alloc] init];
    }
    
    return _customNotification;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    
    fetchDataArray = [self.customNotificationModel fetchAllCustomNotificationData];
    [self.tableView reloadData];
    
    
    [self googleAnalytics];
}

- (void)googleAnalytics
{
    [[[GoogleAnalytics alloc] init] trackPageView:@"Custom Notification Root"];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return fetchDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomNotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"h:mm a";
    
    self.customNotification = fetchDataArray[indexPath.row];
    
    cell.messageLabel.text = self.customNotification.message;
    cell.fireDateLabel.text = [dateFormatter stringFromDate:self.customNotification.fireDate];
    if ([self.customNotification.on boolValue]) {
        cell.onLabel.text = @"開啟";
    } else {
        cell.onLabel.text = @"關閉";
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        for (NSInteger row = 0 ; row < fetchDataArray.count ; row++ )
        {
            if (row == indexPath.row)
            {
                [self.customNotificationModel cancelSpecificCustomNotification:fetchDataArray[indexPath.row] row:indexPath.row];
                fetchDataArray = [self.customNotificationModel fetchAllCustomNotificationData];

                break;
            }
        }
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"detail"]) {
        UIViewController *page2 = segue.destinationViewController;
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        self.customNotification = fetchDataArray[indexPath.row];
        
        [page2 setValue:self.customNotification forKey:@"selectedNotification"];
        [page2 setValue:[NSNumber numberWithInteger:indexPath.row] forKey:@"selectedRow"];
    }
}

@end
