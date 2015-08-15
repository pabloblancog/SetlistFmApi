//
//  SetlistfmAPi.m
//  Setlists
//
//  Created by Pablo Blanco González on 10/05/14.
//  Copyright (c) 2014 Pablo Blanco González. All rights reserved.
//

#import "SetlistfmAPI.h"

@implementation SetlistfmAPI

// Tipos de ficheros a buscar
static NSString* const QUERY_XML_SUFIX =                   @".xml";
static NSString* const FICHERO_XML =                       @"application/xml";
static NSString* const QUERY_JSON_SUFIX =                  @".json";
static NSString* const FICHERO_JSON =                      @"application/json";
static NSString* const QUERY_SUFIX =                       @"?";

// Cadenas para consultas en setlist.fm
static NSString* const SETLISTFM_QUERY_URL_BASE =          @"http://api.setlist.fm/rest/0.1";
static NSString* const SETLISTFM_QUERY_SEARCH =            @"search/";
static NSString* const SETLISTFM_QUERY_SETLIST =           @"setlist/";
static NSString* const SETLISTFM_QUERY_SETLISTS =          @"setlists";
static NSString* const SETLISTFM_QUERY_ARTISTAS =          @"artists";
static NSString* const SETLISTFM_QUERY_ARTISTAS_MBID =     @"artistMbid";
static NSString* const SETLISTFM_QUERY_ARTISTAS_NAME =     @"artistName";
static NSString* const SETLISTFM_QUERY_LUGARES_VENUE =     @"venues";
static NSString* const SETLISTFM_QUERY_LUGARES_CITY =      @"cities";
static NSString* const SETLISTFM_QUERY_LUGARES_COUNTRY =   @"countries";
static NSString* const SETLISTFM_QUERY_VENUE_NAME =        @"venueName";
static NSString* const SETLISTFM_QUERY_CITY_NAME =         @"cityName";
static NSString* const SETLISTFM_QUERY_STATE =             @"state";
static NSString* const SETLISTFM_QUERY_STATE_CODE =        @"stateCode";
static NSString* const SETLISTFM_QUERY_COUNTRY_CODE =      @"countryCode";
static NSString* const SETLISTFM_QUERY_NAME =              @"name";
static NSString* const SETLISTFM_QUERY_DATE =              @"date";
static NSString* const SETLISTFM_QUERY_YEAR =              @"year";
static NSString* const SETLISTFM_QUERY_PAGINA =            @"p";
static NSString* const SETLIST_FM_FORMAT =                 @"dd-MM-yyyy";

#pragma mark - Places search

+(void)findPlacesWithText:(NSString*) searchText
            AndPageToLoad:(NSInteger) pageToLoad
       AndNumberOfRetries:(NSInteger) numberOfRetries
           AndWithSuccess:(void (^)(NSData *places))success andFailure:(void (^)(NSError *))failure {
    
    NSLog(@"finding places with text %@ and page: %ld",searchText, (long)pageToLoad);
    NSError *error = nil;
    
    NSURL *url = [self prepareStringToURL: [NSString stringWithFormat:@"%@/%@%@%@%@%@=%@&%@=%ld",
                                                    SETLISTFM_QUERY_URL_BASE,
                                                    SETLISTFM_QUERY_SEARCH,
                                                    SETLISTFM_QUERY_LUGARES_CITY,
                                                    QUERY_JSON_SUFIX,
                                                    QUERY_SUFIX,
                                                    SETLISTFM_QUERY_NAME,
                                                    searchText,
                                                    SETLISTFM_QUERY_PAGINA,
                                                    (long)pageToLoad]];
    NSLog(@"%@", url);
    NSURLRequest *request = [NSURLRequest requestWithURL: url];
    
    NSHTTPURLResponse * response = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:request
                                          returningResponse:&response
                                                      error:&error];
    BOOL requestSuccess = !error && response.statusCode == 200;
    if (requestSuccess){
        success(data);
    } else {
        if (numberOfRetries <= 0){
            if (response.statusCode == 404){
                // NSURLErrorDomain
                error = [[NSError alloc] initWithDomain:@"domain" code:404 userInfo:nil];
            }
            failure(error);
        } else {
            NSLog(@"Retrying... %ld retries left. ", (long)numberOfRetries);
            [self findPlacesWithText:searchText AndPageToLoad:pageToLoad AndNumberOfRetries:numberOfRetries - 1 AndWithSuccess:success andFailure:failure];
        }
    }
}


#pragma mark - Event search
+(void) findConcertsWithArtist:(ConcertArtist*) artist
                      andPlace:(ConcertPlace*) place
                       andDate:(NSDate*) date
                 andPageToLoad:(NSInteger) pageToLoad
            AndNumberOfRetries:(NSInteger) numberOfRetries
                   WithSuccess:(void (^)(NSData *concerts))success andFailure:(void (^)(NSError *error))failure {
    
    NSLog(@"finding concerts with page: %ld", (long)pageToLoad);
    NSError *error;

    NSURL *URL = [self prepareStringToURL: [self createStringURLWithArtist:artist
                                                                  andPlace:place
                                                                   andDate:date
                                                             andPageToLoad:pageToLoad]];
    NSLog(@"%@", [URL absoluteString]);
    NSURLRequest *request = [NSURLRequest requestWithURL: URL];
    
    NSHTTPURLResponse * response = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:request
                                          returningResponse:&response
                                                      error:&error];
    BOOL requestSuccess = !error && response.statusCode == 200;
    if (requestSuccess){
        success(data);
    } else {
        if (numberOfRetries <= 0){
            if (response.statusCode == 404){
                error = [[NSError alloc] initWithDomain:@"domain" code:404 userInfo:nil];
            }
            failure(error);
        } else {
            NSLog(@"Retrying... %ld retries left. ", (long)numberOfRetries);
            [self findConcertsWithArtist:artist andPlace:place andDate:date andPageToLoad:pageToLoad AndNumberOfRetries:numberOfRetries - 1 WithSuccess:success andFailure:failure];
        }
    }
}


+(NSString*) createStringURLWithArtist:(ConcertArtist*) artist
                              andPlace:(ConcertPlace*) place
                               andDate:(NSDate*) date
                         andPageToLoad:(NSInteger)pageToLoad {

    NSString *searchingType = @"SEARCH_TYPE_";
    
    if (artist){
        searchingType = [[NSString alloc] initWithFormat:@"%@ARTIST", searchingType];
    }
    if (place){
        searchingType = [[NSString alloc] initWithFormat:@"%@PLACE", searchingType];
    }
    if (date){
        searchingType = [[NSString alloc] initWithFormat:@"%@DATE", searchingType];
    }
    
    NSString *URLQuery = [[NSString alloc] init];

    // Artist
    if ([searchingType compare: @"SEARCH_TYPE_ARTIST"] == NSOrderedSame ||
        [searchingType compare: @"SEARCH_TYPE_ARTISTPLACE"] == NSOrderedSame ||
        [searchingType compare: @"SEARCH_TYPE_ARTISTDATE"] == NSOrderedSame ||
        [searchingType compare: @"SEARCH_TYPE_ARTISTPLACEDATE"] == NSOrderedSame){
        URLQuery = [NSString stringWithFormat:@"%@&%@=%@",
                    URLQuery,
                    SETLISTFM_QUERY_ARTISTAS_NAME,
                    artist.artistName];
    }

    // Place
    if ([searchingType compare: @"SEARCH_TYPE_PLACE"] == NSOrderedSame ||
        [searchingType compare: @"SEARCH_TYPE_ARTISTPLACE"] == NSOrderedSame ||
        [searchingType compare: @"SEARCH_TYPE_PLACEDATE"] == NSOrderedSame ||
        [searchingType compare: @"SEARCH_TYPE_ARTISTPLACEDATE"] == NSOrderedSame){

        if (place.placeCity.placeStateCode){
            URLQuery = [NSString stringWithFormat:@"%@&%@=%@&%@=%@&%@=%@",
                        URLQuery,
                        SETLISTFM_QUERY_CITY_NAME,
                        place.placeCity.placeCityName,
                        SETLISTFM_QUERY_COUNTRY_CODE,
                        place.placeCity.placeCountry.placeCountryCode,
                        SETLISTFM_QUERY_STATE_CODE,
                        place.placeCity.placeStateCode
                        ];
        } else {
            URLQuery = [NSString stringWithFormat:@"%@&%@=%@&%@=%@",
                        URLQuery,
                        SETLISTFM_QUERY_CITY_NAME,
                        place.placeCity.placeCityName,
                        SETLISTFM_QUERY_COUNTRY_CODE,
                        place.placeCity.placeCountry.placeCountryCode
                        ];
        }
    }
    
    // Date
    if ([searchingType compare: @"SEARCH_TYPE_DATE"] == NSOrderedSame ||
        [searchingType compare: @"SEARCH_TYPE_ARTISTDATE"] == NSOrderedSame ||
        [searchingType compare: @"SEARCH_TYPE_PLACEDATE"] == NSOrderedSame ||
        [searchingType compare: @"SEARCH_TYPE_ARTISTPLACEDATE"] == NSOrderedSame){
        
        URLQuery = [NSString stringWithFormat:@"%@&%@=%@",
                    URLQuery,
                    SETLISTFM_QUERY_DATE,
                    [NSDate_Utils createStringFromDate:date withFormat: SETLIST_FM_FORMAT]];
    }

    // Page to load
    URLQuery = [NSString stringWithFormat:@"%@&%@=%@",
                URLQuery,
                SETLISTFM_QUERY_PAGINA,
                [NSString stringWithFormat:@"%ld", (long)pageToLoad]];
    
    NSString *URLBase = [self createSearchBaseURL];
    return [NSString stringWithFormat:@"%@%@", URLBase, URLQuery];
}


+(NSString *) createSearchBaseURL {
 
    // Se obtiene la URL base de la busqueda
    NSString *baseURL = [NSString stringWithFormat:@"%@/%@%@%@%@",
                      SETLISTFM_QUERY_URL_BASE,
                      SETLISTFM_QUERY_SEARCH,
                      SETLISTFM_QUERY_SETLISTS,
                      QUERY_JSON_SUFIX,
                      QUERY_SUFIX];
 
    return baseURL;
}

#pragma mark - Concert songs search
+(void) findConcertSongsWithConcertId:(NSString*)concertId
                   AndNumberOfRetries:(NSInteger) numberOfRetries
                          WithSuccess:(void (^)(NSData *concerts))success andFailure:(void (^)(NSError *))failure{
    
    NSError *error;
    NSURL *url = [self prepareStringToURL: [NSString stringWithFormat:@"%@/%@%@%@",
                                            SETLISTFM_QUERY_URL_BASE,
                                            SETLISTFM_QUERY_SETLIST,
                                            concertId,
                                            QUERY_JSON_SUFIX]];
    
    NSLog(@"%@", url);
    NSURLRequest *request = [NSURLRequest requestWithURL: url];
    
    NSHTTPURLResponse * response = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:request
                                          returningResponse:&response
                                                      error:&error];
    BOOL requestSuccess = !error && response.statusCode == 200;
    if (requestSuccess){
        success(data);
    } else {
        if (numberOfRetries <= 0){
            failure(error);
        } else {
            NSLog(@"Retrying... %ld retries left. ", (long)numberOfRetries);
            [self findConcertSongsWithConcertId:concertId AndNumberOfRetries:numberOfRetries - 1 WithSuccess:success andFailure:failure];
        }
    }
}

// Prepare URL string for UTF8 encoding
+ (NSURL*) prepareStringToURL:(NSString *)inputString {
    NSString *escapedString = [inputString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSURL URLWithString: escapedString];
}

@end
