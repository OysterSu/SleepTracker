//
//  CustomNotification.h
//  SleepTracker
//
//  Created by 蘇健豪1 on 2015/3/1.
//  Copyright (c) 2015年 蘇健豪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CustomNotification : NSManagedObject

@property (nonatomic, retain) NSDate * fireDate;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSNumber * on;
@property (nonatomic, retain) NSString * sound;

@end
