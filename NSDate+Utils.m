//
//  NSDate+Utils.m
//  Setlists
//
//  Created by Pablo Blanco González on 29/12/14.
//  Copyright (c) 2014 Pablo Blanco González. All rights reserved.
//

#import "NSDate+Utils.h"

@implementation NSDate_Utils

// Time metrics
static NSInteger const SECONDS_IN_MINUTE = 60;
static NSInteger const MINUTES_IN_HOUR = 60;
static NSInteger const HOURS_IN_DAY = 24;

+(NSDate*) createDateFromString:(NSString *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    return [dateFormatter dateFromString: date];
}

+(NSDate*) createDateFromString:(NSString *)date withFormat:(NSString *)format{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    [dateFormatter setDateFormat:format];
    return [dateFormatter dateFromString: date];
}

+(NSDate*) createDateFromDay:(NSInteger)day andMonth:(NSInteger)month andYear:(NSInteger)year {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:day];
    [comps setMonth:month];
    [comps setYear:year];
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

+(NSString*)createStringFromDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    return [dateFormatter stringFromDate:date];
}

+(NSString*)createStringFromDate: (NSDate *)date withFormat:(NSString *)format{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:date];
}


+(BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate {
    return ([date compare:beginDate] != NSOrderedAscending) && ([date compare:endDate] != NSOrderedDescending);
}

+(NSDate*)addDays:(NSInteger)numberOfDays toDate:(NSDate*)date{
    return [date dateByAddingTimeInterval:SECONDS_IN_MINUTE * MINUTES_IN_HOUR * HOURS_IN_DAY * numberOfDays];
}

+(NSString*)getYearFromDate:(NSDate*)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    [dateFormatter setDateFormat:@"yyyy"];
    return [dateFormatter stringFromDate: date];
}

+(NSString*)getMonthFromDate:(NSDate*)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    [dateFormatter setDateFormat:@"MMM"];
    return [dateFormatter stringFromDate: date];
}

+(NSString*)getDayFromDate:(NSDate*)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    [dateFormatter setDateFormat:@"dd"];
    return [dateFormatter stringFromDate: date];
}

+(NSString*)getUIDateWithStartDate:(NSDate*)startDate andWithEndDate:(NSDate*)endDate {
    
    NSString *date = @"";
    
    if ([endDate compare: startDate] != NSOrderedSame){
        if ([[self getMonthFromDate: startDate] isEqualToString:
             [self getMonthFromDate: endDate]]){
            
            date = [NSString stringWithFormat:@"%@ %@-%@, %@",
                    [self getMonthFromDate: startDate],
                    [self getDayFromDate: startDate],
                    [self getDayFromDate: endDate],
                    [self getYearFromDate: startDate]];
        } else if ([[self getYearFromDate: startDate] isEqualToString:
                    [self getYearFromDate: endDate]]){
            date = [NSString stringWithFormat:@"%@ %@ - %@ %@, %@",
                    [self getMonthFromDate: startDate],
                    [self getDayFromDate: startDate],
                    [self getMonthFromDate: endDate],
                    [self getDayFromDate: endDate],
                    [self getYearFromDate: startDate]];
        } else {
            date = [NSString stringWithFormat:@"%@ - %@",
                    [self createStringFromDate: startDate],
                    [self createStringFromDate: endDate]];
        }
    } else {
        date = [self createStringFromDate: startDate];
    }
    
    return date;
}

@end
