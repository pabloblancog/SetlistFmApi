//
//  NSDate+Utils.h
//  Setlists
//
//  Created by Pablo Blanco González on 29/12/14.
//  Copyright (c) 2014 Pablo Blanco González. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate_Utils : NSDate

+(NSDate*) createDateFromString:(NSString *)date;
+(NSDate*) createDateFromString:(NSString *)date withFormat:(NSString *)format;
+(NSString*) createStringFromDate:(NSDate *)date;
+(NSString*) createStringFromDate:(NSDate *)date withFormat:(NSString *)format;
+(BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate;
+(NSDate*)addDays:(NSInteger)numberOfDays toDate:(NSDate*)date;
+(NSString*)getYearFromDate:(NSDate*)date;
+(NSString*)getMonthFromDate:(NSDate*)date;
+(NSString*)getDayFromDate:(NSDate*)date;
+(NSString*)getUIDateWithStartDate:(NSDate*)startDate andWithEndDate:(NSDate*)endDate;

@end
