//
//  SetlistfmAPi.h
//  Setlists
//
//  Created by Pablo Blanco González on 10/05/14.
//  Copyright (c) 2014 Pablo Blanco González. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConcertsSearch.h"
#import "NSDate+Utils.h"

@interface SetlistfmAPI : NSObject

+(void)findPlacesWithText:(NSString*) searchText
            AndPageToLoad:(NSInteger) pageToLoad
       AndNumberOfRetries:(NSInteger) numberOfRetries
           AndWithSuccess:(void (^)(NSData *places))success andFailure:(void (^)(NSError *))failure;

+(void) findConcertsWithArtist:(ConcertArtist*) artist
                      andPlace:(ConcertPlace*) place
                       andDate:(NSDate*) date
                 andPageToLoad:(NSInteger) pageToLoad
            AndNumberOfRetries:(NSInteger) numberOfRetries
                   WithSuccess:(void (^)(NSData *concerts))success andFailure:(void (^)(NSError *))failure;

+(void) findConcertSongsWithConcertId:(NSString*)concertId
                   AndNumberOfRetries:(NSInteger) numberOfRetries
                          WithSuccess:(void (^)(NSData *concerts))success andFailure:(void (^)(NSError *))failure;
@end
