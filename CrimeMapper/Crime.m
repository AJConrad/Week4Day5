//
//  Crime.m
//  CrimeMapper
//
//  Created by Andrew Conrad on 5/6/16.
//  Copyright © 2016 AndrewConrad. All rights reserved.
//

#import "Crime.h"

@implementation Crime

- (id)initWithCrimeType:(NSString *)crimeType andAddress:(NSString *)address andCoordLatitude:(NSString *)coordLatitude andCoordLongitude:(NSString *)coordLongitude;
{
    self = [super init];
    if (self) {
        self.address = address;
        self.coordLatitude = coordLatitude;
        self.coordLongitude = coordLongitude;
        self.crimeType = crimeType;
    }
    return self;
}

@end
