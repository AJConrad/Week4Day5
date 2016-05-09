//
//  Precinct.m
//  CrimeMapper
//
//  Created by Andrew Conrad on 5/5/16.
//  Copyright © 2016 AndrewConrad. All rights reserved.
//

#import "Precinct.h"

@implementation Precinct

- (id) initWithPrecinctID:(NSString *)precinctID andAddress:(NSString *)address andCoordLatitude:(NSString *)coordLatitude andCoordLongitude:(NSString *)coordLongitude;
{
    self = [super init];
    if (self) {
        self.address = address;
        self.coordLatitude = coordLatitude;
        self.coordLongitude = coordLongitude;
        self.precinctID = precinctID;
    }
    return self;
}

@end
