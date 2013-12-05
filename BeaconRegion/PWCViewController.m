//
//  PWCViewController.m
//  BeaconRegion
//
//  Created by Ravi on 5/12/2013.
//  Copyright (c) 2013 PwC. All rights reserved.
//

#import "PWCViewController.h"

static NSString * const kSpreadsheetURL = @"https://docs.google.com/forms/d/1ctrAHWmIz-j_47LjRdWPnzHE8ELHjE_MW1X984p3csw/formResponse";
static NSString * const kUUID = @"B9407F30-F5F8-466E-AFF9-25556B57FE6D";

static NSString * const kBlueRegionIdentifier = @"au.com.pwc.BlueBeacon";
static NSString * const kGreenRegionIdentifier = @"au.com.pwc.GreenBeacon";
static NSString * const kPurpleRegionIdentifier = @"au.com.pwc.PurpleBeacon";

//Blue beacon Major:394 Minor:58605
//Green beacon  Major:40836 Minor:18108
//Purple beacon Major:29836 Minor:57466

@interface PWCViewController ()

@property (nonatomic, strong) CLLocationManager * locationManager;

@property BOOL isFBdataFetched;

@property (nonatomic, strong) NSMutableDictionary *userData;

@property (nonatomic, strong) NSDate * regionEntryTime;
@property (nonatomic, strong) NSDate * regionExitTime;
@property NSTimeInterval timeInterval;


@end

@implementation PWCViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self authFacebook];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = 2.0; // two meters
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    CLBeaconRegion *region;
    NSUUID *estimoteUUID = [[NSUUID alloc] initWithUUIDString:kUUID];
    
    // Blue Estimote
    region = [[CLBeaconRegion alloc] initWithProximityUUID:estimoteUUID
                                                     major:394
                                                     minor:58605
                                                identifier:kBlueRegionIdentifier];
    
    // launch app when display is turned on and inside region
    region.notifyEntryStateOnDisplay = YES;
    //To prevent redundant notifications from being delivered to the user
    region.notifyOnEntry = NO;
    
    if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        [_locationManager startMonitoringForRegion:region];
        
        // get status update right away for UI
        //        [_locationManager requestStateForRegion:region];
        
        //        // Start ranging for beacons
        //        [_locationManager startRangingBeaconsInRegion:self.region];
        
    } else {
        NSLog(@"This device does not support monitoring beacon regions");
    }
    
    // Green Estimote
    region = [[CLBeaconRegion alloc] initWithProximityUUID:estimoteUUID
                                                     major:40836
                                                     minor:18108
                                                identifier:kGreenRegionIdentifier];
    
    // launch app when display is turned on and inside region
    region.notifyEntryStateOnDisplay = YES;
    //To prevent redundant notifications from being delivered to the user
    region.notifyOnEntry = NO;
    
    if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        [_locationManager startMonitoringForRegion:region];
        
        // get status update right away for UI
        //        [_locationManager requestStateForRegion:region];
        
    } else {
        NSLog(@"This device does not support monitoring beacon regions");
    }
    
    // Green Estimote
    region = [[CLBeaconRegion alloc] initWithProximityUUID:estimoteUUID
                                                     major:29836
                                                     minor:57466
                                                identifier:kPurpleRegionIdentifier];
    
    // launch app when display is turned on and inside region
    region.notifyEntryStateOnDisplay = YES;
    //To prevent redundant notifications from being delivered to the user
    region.notifyOnEntry = NO;
    
    if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        [_locationManager startMonitoringForRegion:region];
        
        // get status update right away for UI
        //        [_locationManager requestStateForRegion:region];
        
    } else {
        NSLog(@"This device does not support monitoring beacon regions");
    }
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.offerImage.image = [UIImage imageNamed:@"iconBeacon"];
    self.userData = [[NSMutableDictionary alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setProductOfferWithRegionIdentifer:(NSString *)identifier
{
    if ([identifier isEqualToString:kBlueRegionIdentifier]) {
        self.offerImage.image = [UIImage imageNamed:@"blue_promotion"];
        
    } else if ([identifier isEqualToString:kGreenRegionIdentifier]) {
        self.offerImage.image = [UIImage imageNamed:@"green_promotion"];
        
    } else if ([identifier isEqualToString:kPurpleRegionIdentifier]) {
        self.offerImage.image = [UIImage imageNamed:@"purple_promotion"];
        
    } else {
        self.offerImage.image = [UIImage imageNamed:@"purpleNotificationBig"];
    }
    
}

// relative distance string value to beacon
- (NSString *)proxmityString:(CLProximity)proximity
{
    NSString *proximityString;
    
    switch (proximity) {
        case CLProximityNear:
            proximityString = @"Near";
            break;
        case CLProximityImmediate:
            proximityString = @"Immediate";
            break;
        case CLProximityFar:
            proximityString = @"Far";
            break;
        case CLProximityUnknown:
        default:
            proximityString = @"Unknown";
            break;
    }
    
    return proximityString;
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager
	  didDetermineState:(CLRegionState)state
              forRegion:(CLRegion *)region
{
    
    NSLog(@"Region %@ identifier", region.identifier );
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
//        [self setProductOfferWithRegionIdentifer:region.identifier];
        
        // don't send any notifications if app is open
        return;
    }
    
}

- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region
{
    NSLog(@"Inside Region %@", region.identifier);
    // A user can transition in or out of a region while the application is not running.
    // When this happens CoreLocation will launch the application momentarily, call this delegate method
    // and we will let the user know via a local notification.
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    self.regionEntryTime = [NSDate date];
    
    NSLog(@"Region Entry Time: %@", self.regionEntryTime);
    
    notification.alertBody = @"You're inside the region";
    
    [self setProductOfferWithRegionIdentifer:region.identifier];
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
}

- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region
{
    NSLog(@"Outside Region %@", region.identifier);
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    
    self.timeInterval = [[NSDate date] timeIntervalSinceDate:self.regionEntryTime];
    self.regionExitTime = [NSDate date];
    
    
    NSLog(@"Region Exit Time: %@", self.regionExitTime);
    NSLog(@"Time Interval: %f", self.timeInterval);
    
    
    notification.alertBody = @"You're outside the region";
    
    if (_isFBdataFetched) {
        [self postDataToSpreadsheetViaForm:region];
    }
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark FacebookSDK

- (void)authFacebook
{
    // Login or get user data from Facebook
    NSArray *permissions = @[@"basic_info", @"email"];
    if (self.session.isOpen) {
        //        NSLog(@"%@ accessToken", fbTokenData);
        //        [self fetchFBUserData];
        
    } else {
        //Login with Facebook native login diaglog
        [FBSession openActiveSessionWithReadPermissions:permissions
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                          
                                          if (!error) {
                                              NSLog(@"== Login Success %@ session, %d status", session, status);
                                              self.session = session;
                                              [self fetchFBUserData];
                                              
                                          } else {
                                              NSLog(@"%@ error!", error);
                                          }
                                          
                                          
                                      }];
        
    }
}

// Fetch basic userinfo and email from Facebook
- (void)fetchFBUserData
{
    //    [FBSettings setLoggingBehavior:[NSSet setWithObjects:
    //                                    FBLoggingBehaviorFBRequests, nil]];
    
    // Fetch user data
    [FBRequestConnection
     startForMeWithCompletionHandler:^(FBRequestConnection *connection,
                                       id<FBGraphUser> user,
                                       NSError *error) {
         if (!error) {
             NSString *userInfo = @"";
             
             self.userData[@"fb_id"] = user.id;
             // Example: typed access (name)
             // - no special permissions required
             userInfo = [userInfo
                         stringByAppendingString:
                         [NSString stringWithFormat:@"Name: %@\n\n",
                          user.name]];
             self.userData[@"name"] = user.name;
             
             // Example: typed access (name)
             // - no special permissions required
             userInfo = [userInfo
                         stringByAppendingString:
                         [NSString stringWithFormat:@"Gender: %@\n\n",
                          user[@"gender"]]];
             
             self.userData[@"gender"] = user[@"gender"];
             
             // Example: typed access (email)
             // - email permission required
             userInfo = [userInfo
                         stringByAppendingString:
                         [NSString stringWithFormat:@"Email: %@\n\n",
                          user[@"email"]]];
             
             self.userData[@"email"] = user[@"email"];
             
             NSLog(@"=== FB UserInfo === \n%@", userInfo);
             
             //             [[NSNotificationCenter defaultCenter] postNotificationName:@"FBDataFetched" object:nil];
             
             _isFBdataFetched = YES;
         }
     }];
    
}


#pragma mark - GDataAPI

// spreadsheet cells
# define EST_UUID       @"entry.1641994124"
# define MAJOR          @"entry.857825636"
# define MINOR          @"entry.1767879955"
# define RSSI           @"entry.1246457524"
# define FB_ID          @"entry.678980662"
# define FB_FULL_NAME   @"entry.1448375634"
# define FB_GENDER      @"entry.1424146187"
# define FB_EMAIL       @"entry.2006994834"


- (void)postDataToSpreadsheetViaForm:(CLRegion *)region
{
    NSURL *url = [[NSURL alloc] initWithString:kSpreadsheetURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSLog(@"%@ User Data", self.userData);

    NSString *params = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@",
                        EST_UUID, [NSString stringWithFormat:@"%f", self.timeInterval],
                        MAJOR, [self dateStringWithDSTOffset:self.regionEntryTime],
                        MINOR, [self dateStringWithDSTOffset:self.regionExitTime],
                        RSSI, region.identifier,
                        FB_ID, self.userData[@"fb_id"],
                        FB_FULL_NAME, self.userData[@"name"],
                        FB_GENDER, self.userData[@"gender"],
                        FB_EMAIL, self.userData[@"email"] ];
    
    NSData *paramsData = [params dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:paramsData];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               if (data.length > 0 && connectionError == nil) {
                                   NSLog(@"== Successfully posted data ==");
                                   
                               } else if (data.length == 0 && connectionError == nil) {
                                   NSLog(@"No data");
                                   
                               } else if (connectionError != nil) {
                                   NSLog(@"Connection Error %@", connectionError);
                               }
                               
                           }];
    
}

// offset date if daylight saving is on
- (NSString *)dateStringWithDSTOffset:(NSDate *)date
{
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setTimeZone:[NSTimeZone localTimeZone]];
    [df setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    return [df stringFromDate:date];
}

@end
