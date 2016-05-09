//
//  Bar.m
//  CrimeMapper
//
//  Created by Andrew Conrad on 5/6/16.
//  Copyright © 2016 AndrewConrad. All rights reserved.
//

#import "Bar.h"

@implementation Bar

-(id)initWithBarName:(NSString *)barName andAddress:(NSString *)address andCoordLatitude:(NSString *)coordLatitude andCoordLongitude:(NSString *)coordLongitude;
{
    self = [super init];
    if (self) {
        self.address = address;
        self.coordLatitude = coordLatitude;
        self.coordLongitude = coordLongitude;
        self.barName = barName;
    }
    return self;
}

@end
