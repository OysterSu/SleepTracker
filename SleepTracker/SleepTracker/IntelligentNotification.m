//
//  IntelligentNotification.m
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/1/22.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import "IntelligentNotification.h"

#import "LocalNotification.h"
#import "SleepDataModel.h"
#import "SleepData.h"
#import "Statistic.h"

@interface IntelligentNotification ()

@property (strong, nonatomic) NSDate *shouldGoToBedTime;

@property (strong, nonatomic) LocalNotification *localNotification;
@property (strong, nonatomic) SleepDataModel *sleepDataModel;
@property (strong, nonatomic) NSArray *fetchArray;
@property (strong, nonatomic) SleepData *sleepData;

@property (strong, nonatomic) Statistic *statistic;

@end

@implementation IntelligentNotification

@synthesize shouldGoToBedTime, fetchArray;

#pragma mark - Lazy initialization

- (LocalNotification *)localNotification
{
    if (!_localNotification) {
        _localNotification = [[LocalNotification alloc] init];
    }
    return _localNotification;
}

- (SleepDataModel *)sleepDataModel
{
    if (!_sleepDataModel) {
        _sleepDataModel = [[SleepDataModel alloc] init];
    }
    return _sleepDataModel;
}

#pragma mark - Decide

- (NSDate *)decideShouldGoToBedTime
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setHour:23];
    [components setMinute:0];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];  //NSCalendarIdentifierGregorian
    shouldGoToBedTime = [calendar dateFromComponents:components];

    
    return shouldGoToBedTime;
}

- (NSArray *)decideNotificationTitle
{
    NSArray *notification = @[@"吃東西", @"看任何電子螢幕", @"洗澡", @"平均上床時間", @"醒來超過十六小時"];
    
    return notification;
}

- (NSArray *)decideMessage
{
    NSArray *message = @[@"如果你想要在%@時去睡覺，建議你就不要再吃東西了。",
                         @"建議你不要再看任何電子螢幕了，好讓眼睛開始休息。",
                         @"如果你想要在十一點時上床睡覺，建議你可以現在去沖個澡，這樣兩個小時後體溫開始下降，正好適合睡覺。",
                         @"已經過了你平均上床的時間了，建議妳趕快上床休息吧。",
                         @"從你今天起床醒來到現在已經超過十六個小時了，建議你盡快去上床休息吧。"];
    
    return message;
}

- (NSArray *)decideFireDate
{
    fetchArray = [self.sleepDataModel fetchSleepDataSortWithAscending:NO];
    NSInteger const LATEST_DATA = 0;
    self.sleepData = fetchArray[LATEST_DATA];
    
    [self decideShouldGoToBedTime];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];  //NSCalendarIdentifierGregorian
    
    self.statistic = [[Statistic alloc] init];
    NSInteger averageGoToSleepTimeInSecond = [[[self.statistic showGoToBedTimeDataInTheRecent:7] objectAtIndex:2] integerValue];
    [components setHour:averageGoToSleepTimeInSecond / 3600];
    [components setMinute:((averageGoToSleepTimeInSecond / 60) % 60)];
    NSDate *averageGoToSleepTime = [calendar dateFromComponents:components];
    
    
    NSArray *fireDate = [[NSArray alloc] initWithObjects:
                         [NSDate dateWithTimeInterval:-(60 * 60 * 3) sinceDate:shouldGoToBedTime],
                         [NSDate dateWithTimeInterval:-(60 * 60 * 1) sinceDate:shouldGoToBedTime],
                         [NSDate dateWithTimeInterval:-(60 * 60 * 2) sinceDate:shouldGoToBedTime],
                         averageGoToSleepTime,
                         [NSDate dateWithTimeInterval:(60 * 60 * 16) sinceDate:self.sleepData.wakeUpTime], nil];
    return fireDate;
}

#pragma mark - Reschedule

- (void)rescheduleIntelligentNotification
{
    [self deleteAllIntelligentNotification];
    
    NSArray *notification = [self decideNotificationTitle];
    NSArray *Message = [self decideMessage];
    NSArray *fireDate = [self decideFireDate];
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    
    for (NSInteger i = 0 ; i < [notification count] ; i++ ) {
        if ([userPreferences boolForKey:notification[i]]) {
            [self.localNotification setLocalNotificationWithMessage:Message[i]
                                                           fireDate:fireDate[i]
                                                        repeatOrNot:YES
                                                              Sound:@"UILocalNotificationDefaultSoundName"
                                                           setValue:@"IntelligentNotification" forKey:@"NotificationType"];
        }
    }
}

#pragma mark - Delete

- (void)deleteAllIntelligentNotification
{
    UIApplication *application = [UIApplication sharedApplication];
    NSArray *arrayOfAllLocalNotification = [application scheduledLocalNotifications];
    UILocalNotification *localNotification;
    NSDictionary *userInfo;
    NSString *value;
    
    for (NSInteger row = 0 ; row < arrayOfAllLocalNotification.count ; row++ )
    {
        localNotification = arrayOfAllLocalNotification[row];
        
        userInfo = localNotification.userInfo;
        value = [userInfo objectForKey:@"NotificationType"];
        
        if ([value isEqualToString:@"IntelligentNotification"])
        {
            [application cancelLocalNotification:localNotification];
        }
    }
}

@end
