//
//  Precinct.h
//  CrimeMapper
//
//  Created by Andrew Conrad on 5/5/16.
//  Copyright © 2016 AndrewConrad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Precinct : NSObject

@property (nonatomic, strong)   NSString        *coordLatitude;
@property (nonatomic, strong)   NSString        *coordLongitude;
@property (nonatomic, strong)   NSString        *address;
@property (nonatomic, strong)   NSString        *precinctID;

- (id) initWithPrecinctID:(NSString *)precinctID andAddress:(NSString *)address andCoordLatitude:(NSString *)coordLatitude andCoordLongitude:(NSString *)coordLongitude;


@end
