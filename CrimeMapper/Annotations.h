//
//  Annotations.h
//  CrimeMapper
//
//  Created by Andrew Conrad on 5/5/16.
//  Copyright © 2016 AndrewConrad. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface Annotations : MKPointAnnotation

@property (nonatomic, strong)       NSNumber        *pinIndex;
@property (nonatomic, strong)       NSString        *pinType;

@end
