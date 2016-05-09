//
//  AppDelegate.h
//  CrimeMapper
//
//  Created by Andrew Conrad on 5/5/16.
//  Copyright © 2016 AndrewConrad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//Data Arrays
@property (nonatomic, strong)           NSMutableArray              *precinctArray;
@property (nonatomic, strong)           NSMutableArray              *barArray;
@property (nonatomic, strong)           NSMutableArray              *crimeArray;
//add more data arrays here

@end

