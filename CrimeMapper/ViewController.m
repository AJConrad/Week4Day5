//
//  ViewController.m
//  CrimeMapper
//
//  Created by Andrew Conrad on 5/5/16.
//  Copyright © 2016 AndrewConrad. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "ViewController.h"
#import "AppDelegate.h"
#import "Precinct.h"
#import "Bar.h"
#import "Crime.h"
#import "Reachability.h"
#import "Annotations.h"

@interface ViewController ()

//Core data properties
@property(nonatomic, strong)                        AppDelegate             *appDelegate;
@property(nonatomic, strong)                        NSString                *hostName;

//Map properties
@property(nonatomic, strong)        IBOutlet        MKMapView               *crimeMap;
//maybe i dont need this one, test and remove once cops+cars populate
@property(nonatomic, strong)                        NSNumber                *selectedPinIndex;

//weblink for precincts is https://data.detroitmi.gov/resource/3n6r-g9kp.json
//weblink for bars is https://data.detroitmi.gov/resource/djd8-sm8q.json?active=Y
//weblink for crimes is https://data.detroitmi.gov/resource/8p3f-52zg.json?$q=assault
@end

@implementation ViewController

//Reachability pointers or values, still dont know terminology
Reachability *hostReach;
Reachability *internetReach;
Reachability *wifiReach;
bool internetAvailable;
bool serverAvailable;

#pragma mark - Police Data Methods

- (void)populatePoliceAnnots {
    
    NSMutableArray *pinsToRemove = [[NSMutableArray alloc] init];
    for (id <MKAnnotation> annot in [_crimeMap annotations]) {
        if ([annot isKindOfClass:[MKPointAnnotation class]]) {
            Annotations *policeAnnot = (Annotations *)annot;
            if ([policeAnnot.pinType isEqualToString:@"police"]) {
                [pinsToRemove addObject:annot];
            }
        }
    }
    [_crimeMap removeAnnotations:pinsToRemove];
    
    for (Precinct *currentPrecinct in _appDelegate.precinctArray) {
        Annotations *pre1 = [[Annotations alloc] init];
        float latitude = [currentPrecinct.coordLatitude floatValue];
        float longitude = [currentPrecinct.coordLongitude floatValue];
        pre1.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        //add spheres of influence here maybe?
        pre1.title = currentPrecinct.precinctID;
        pre1.subtitle = currentPrecinct.address;
        pre1.pinIndex = [NSNumber numberWithLong:[_appDelegate.precinctArray indexOfObject:currentPrecinct]];
        pre1.pinType = @"police";
        [_crimeMap addAnnotation:pre1];
    }
        [_crimeMap showAnnotations:[_crimeMap annotations] animated:true];
}


- (void)parsePoliceJSON {
    
    if (serverAvailable) {
        
        NSURL *policeURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/resource/3n6r-g9kp.json",_hostName]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:policeURL];
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [request setTimeoutInterval:30.0];
        NSURLSession *policeSession = [NSURLSession sharedSession];
        [[policeSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (([data length] > 0) && (error == nil)) {
                NSJSONSerialization *policeJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                NSArray *policeTempArray = (NSArray *)policeJson;
                _appDelegate.precinctArray = [[NSMutableArray alloc] init];
                
                for (NSDictionary *policeDict in policeTempArray) {
                    NSDictionary *coordDict = [policeDict objectForKey:@"location"];
                    NSArray *coords = [coordDict objectForKey:@"coordinates"];
                    Precinct *newPrecinct = [[Precinct alloc]
                                             initWithPrecinctID:[policeDict objectForKey:@"id"]
                                             andAddress:[policeDict objectForKey:@"address_1"]
                                             andCoordLatitude:coords[1]
                                             andCoordLongitude:coords[0]];
                    
                    [_appDelegate.precinctArray addObject:newPrecinct];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self populatePoliceAnnots];
                });
            }
        }] resume];
    }
}

#pragma mark - Bar Data Methods

- (void)populateBarAnnots {
    
    NSMutableArray *pinsToRemove = [[NSMutableArray alloc] init];
    for (id <MKAnnotation> annot in [_crimeMap annotations]) {
        if ([annot isKindOfClass:[MKPointAnnotation class]]) {
            Annotations *barAnnot = (Annotations *)annot;
            if ([barAnnot.pinType isEqualToString:@"bar"]) {
                [pinsToRemove addObject:annot];
            }
        }
    }
    [_crimeMap removeAnnotations:pinsToRemove];
    
    for (Bar *currentBar in _appDelegate.barArray) {
        Annotations *bar1 = [[Annotations alloc] init];
        float latitude = [currentBar.coordLatitude floatValue];
        float longitude = [currentBar.coordLongitude floatValue];
        bar1.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        //make them medium size circles
        bar1.title = currentBar.barName;
        bar1.subtitle = currentBar.address;
        bar1.pinType = @"bar";
        bar1.pinIndex = [NSNumber numberWithLong:[_appDelegate.barArray indexOfObject:currentBar]];
        
        [_crimeMap addAnnotation:bar1];
    }
}

- (void)parseBarJSON {
    
    if (serverAvailable) {
        NSURL *barURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/resource/djd8-sm8q.json?active=Y",_hostName]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:barURL];
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [request setTimeoutInterval:30.0];
        NSURLSession *barSession = [NSURLSession sharedSession];
        [[barSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (([data length] > 0) && (error == nil)) {
                NSJSONSerialization *barJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                NSArray *barTempArray = (NSArray *)barJson;
                _appDelegate.barArray = [[NSMutableArray alloc] init];
                
                for (NSDictionary *barDict in barTempArray) {
                    NSDictionary *coordDict = [barDict objectForKey:@"full_address_value"];
                    NSArray *coords = [coordDict objectForKey:@"coordinates"];
                    Bar *newBar = [[Bar alloc]
                                   initWithBarName:[barDict objectForKey:@"name"]
                                   andAddress:[barDict objectForKey:@"full_address_value_address"]
                                   andCoordLatitude:coords[1]
                                   andCoordLongitude:coords[0]];
                                   
                    [_appDelegate.barArray addObject:newBar];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self populateBarAnnots];
                });
            }
        }] resume];
    }
}

#pragma mark - Crime Data Methods

- (void)populateCrimeAnnots {
    
    NSMutableArray *pinsToRemove = [[NSMutableArray alloc] init];
    for (id <MKAnnotation> annot in [_crimeMap annotations]) {
        if ([annot isKindOfClass:[MKPointAnnotation class]]) {
            Annotations *crimeAnnot = (Annotations *)annot;
            if ([crimeAnnot.pinType isEqualToString:@"crime"]) {
                [pinsToRemove addObject:annot];
            }
        }
    }
    [_crimeMap removeAnnotations:pinsToRemove];
    
    for (Crime *currentCrime in _appDelegate.crimeArray) {
        Annotations *crime1 = [[Annotations alloc] init];
        float latitude = [currentCrime.coordLatitude floatValue];
        float longitude = [currentCrime.coordLongitude floatValue];
        crime1.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        //make them tiny points
        crime1.title = currentCrime.crimeType;
        crime1.subtitle = currentCrime.address;
        crime1.pinType = @"crime";
        crime1.pinIndex = [NSNumber numberWithLong:[_appDelegate.crimeArray indexOfObject:currentCrime]];
        
        [_crimeMap addAnnotation:crime1];
    }
    
}

- (void)parseCrimeJSON {
    
    if (serverAvailable) {
        
        NSURL *crimeURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/resource/8p3f-52zg.json?$q=assault",_hostName]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:crimeURL];
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [request setTimeoutInterval:30.0];
        NSURLSession *crimeSession = [NSURLSession sharedSession];
        [[crimeSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (([data length] >0) && (error == nil)) {
                NSJSONSerialization *crimeJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                NSArray *crimeTempArray = (NSArray *)crimeJSON;
                _appDelegate.crimeArray = [[NSMutableArray alloc] init];
                
                for (NSDictionary *crimeDict in crimeTempArray) {
                    NSDictionary *coordDict = [crimeDict objectForKey:@"location"];
                    NSArray *coords = [coordDict objectForKey:@"coordinates"];
                    Crime *newCrime = [[Crime alloc]
                                       initWithCrimeType:[crimeDict objectForKey:@"category"]
                                       andAddress:[crimeDict objectForKey:@"location_address"]
                                       andCoordLatitude:coords[1]
                                       andCoordLongitude:coords[0]];
                    
                    [_appDelegate.crimeArray addObject:newCrime];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self populateCrimeAnnots];
                });
            }
        }] resume];
    }
}


#pragma mark - Map View Methods



-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if (annotation != mapView.userLocation) {
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
        if (pinView == nil) {
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
        }
        pinView.canShowCallout = true;
        pinView.animatesDrop = false;
        Annotations *annot = (Annotations *)annotation;
        if ([annot.pinType isEqualToString:@"bar"]) {
            pinView.pinTintColor = [UIColor greenColor];
            pinView.alpha = 0.1;
        } else if ([annot.pinType isEqualToString:@"crime"]) {
            pinView.pinTintColor = [UIColor redColor];
            pinView.alpha = 0.1;
        } else if ([annot.pinType isEqualToString:@"police"]) {
            pinView.pinTintColor = [UIColor blueColor];
        }
        
        return pinView;
    }
    return nil;
}

#pragma mark - Network Methods

- (void)updateReachabilityStatus:(Reachability *)currentReach {
    NSParameterAssert([currentReach isKindOfClass:[Reachability class]]);
    NetworkStatus netStatus = [currentReach currentReachabilityStatus];
    if (currentReach == hostReach) {
        switch (netStatus) {
            case NotReachable:
                NSLog(@"Server Not Available");
                serverAvailable = false;
                break;
            case ReachableViaWWAN:
                NSLog(@"Server Reachable via WWAN");
                serverAvailable = true;
            case ReachableViaWiFi:
                NSLog(@"Server Reachable via WiFi");
                serverAvailable = true;
            default:
                break;
        }
    }
    if (currentReach == internetReach || currentReach == wifiReach) {
        switch (netStatus) {
            case NotReachable:
                NSLog(@"Internet Not Available");
                internetAvailable = false;
                break;
            case ReachableViaWWAN:
                NSLog(@"Internet Available via WWAN");
                internetAvailable = true;
            case ReachableViaWiFi:
                NSLog(@"Internet Available via WiFi");
                internetAvailable = true;
            default:
                break;
        }
    }
    [self parsePoliceJSON];
    [self parseBarJSON];
    [self parseCrimeJSON];
//    NSLog(@"Crime count %li",_appDelegate.crimeArray.count);
//    NSLog(@"Bar Count %li",_appDelegate.barArray.count);
}


- (void)reachabilityChanged:(NSNotification *)notification {
    Reachability *currentReach = [notification object];
    [self updateReachabilityStatus:currentReach];
}

#pragma mark - Life Cycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    _hostName = @"data.detroitmi.gov";
    
    //Reachability Checks
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    hostReach = [Reachability reachabilityWithHostname:_hostName];
    [hostReach startNotifier];
    internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
    wifiReach = [Reachability reachabilityForLocalWiFi];
    [wifiReach startNotifier];
    _appDelegate = [[UIApplication sharedApplication] delegate];
    

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:true];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
