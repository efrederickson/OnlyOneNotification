#import <substrate.h>
#import "FSSwitchDataSource.h"
#import "FSSwitchPanel.h"
#import "FSSwitchState.h"

@interface BBBulletin
- (id)title;
@end

static BOOL enabled = YES;
static BOOL disableNoise = YES;
static BOOL blockFirstAsWell = YES;
static NSMutableDictionary *notifs = [[NSMutableDictionary alloc] init];
static BOOL blockAfterFirstOfEachTitle = YES;
static BOOL allowAfterAWhile = YES;
static int timeToWait = 90;
static NSDate *lastNotificationTime = nil;
static BOOL disableWhenRinger = NO;
static BOOL onlyReEnableNoise = YES;

static void reloadSettings(CFNotificationCenterRef center,
                                    void *observer,
                                    CFStringRef name,
                                    const void *object,
                                    CFDictionaryRef userInfo)
{
    NSDictionary *prefs = [NSDictionary 
        dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.lodc.ios.oonsettings.plist"];
    
    if ([prefs objectForKey:@"enabled"] != nil)
        enabled = [[prefs objectForKey:@"enabled"] boolValue];
    else
        enabled = YES;
 
    if ([prefs objectForKey:@"disableNoise"] != nil)    
        disableNoise = [[prefs objectForKey:@"disableNoise"] boolValue];
    else
        disableNoise = YES;

    if ([prefs objectForKey:@"blockFirstAsWell"] != nil)    
        blockFirstAsWell = [[prefs objectForKey:@"blockFirstAsWell"] boolValue];
    else
        blockFirstAsWell = NO;

    if ([prefs objectForKey:@"blockAfterFirstOfEachTitle"] != nil)    
        blockAfterFirstOfEachTitle = [[prefs objectForKey:@"blockAfterFirstOfEachTitle"] boolValue];
    else
        blockAfterFirstOfEachTitle = YES;

    if ([prefs objectForKey:@"allowAfterAWhile"] != nil)    
        allowAfterAWhile = [[prefs objectForKey:@"allowAfterAWhile"] boolValue];
    else
        allowAfterAWhile = YES;

    if ([prefs objectForKey:@"timeToWait"] != nil)    
        timeToWait = [[prefs objectForKey:@"timeToWait"] intValue];
    else
        timeToWait = 90;

    if ([prefs objectForKey:@"disableWhenRinger"] != nil)
        disableWhenRinger = [[prefs objectForKey:@"disableWhenRinger"] boolValue];
    else
        disableWhenRinger = NO;

    if ([prefs objectForKey:@"onlyReEnableNoise"] != nil)
        onlyReEnableNoise = [[prefs objectForKey:@"onlyReEnableNoise"] boolValue];
    else
        onlyReEnableNoise = YES;

    //NSLog(@"OnlyOneNotification: preferences updated");
    //NSLog(@"OnlyOneNotification: DisableAll, disableNoise: %@ , %@", blockFirstAsWell ? @"yes" : @"no", disableNoise ? @"yes" : @"no");
}

static BOOL hasItBeenAWhile()
{
    NSDate *now = [NSDate date];

    NSTimeInterval distanceBetweenDates = [now timeIntervalSinceDate:lastNotificationTime];

    if (distanceBetweenDates > (timeToWait * 60))
        return true;
    return false;
}

static int updateCount(NSString *item)
{
    if (item == nil)
        return 0;

    id i1 = [notifs objectForKey:item];
    int count;
    if (i1 == nil)
        count = 0;
    else
        count = [i1 intValue] + 1;

    [notifs setObject:[NSNumber numberWithInt:count] forKey:item];
    return count;
}

/*
static int getCount(NSString *item)
{
    if (item == 
    id i1 = [notifs objectForKey:item];
    int count;
    if (i1 == nil)
        count = 0;
    else
        count = [i1 intValue];
    return count;
}
*/

%hook SBLockScreenNotificationListController

- (void)turnOnScreenIfNecessaryForItem:(BBBulletin*)arg1
{
    NSMutableArray *li = MSHookIvar<NSMutableArray *>(self, "_listItems");

    BOOL ringer = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.ringer"] == FSSwitchStateOn ? YES : NO;
    BOOL inverse_disableForRinger = disableWhenRinger ? !ringer : YES;
    inverse_disableForRinger = onlyReEnableNoise ? YES : inverse_disableForRinger;

    if ([li count] > (blockFirstAsWell ? 0 : 1) && enabled && blockAfterFirstOfEachTitle == NO && inverse_disableForRinger)
    {
        if (allowAfterAWhile)
        {
            if (hasItBeenAWhile())
            { }
            else 
            {
                lastNotificationTime = [[NSDate date] retain];
                return;
            }
        }
        else
        {
            lastNotificationTime = [[NSDate date] retain];
            return;
        }
    }

    if (enabled && blockAfterFirstOfEachTitle && updateCount([arg1 title]) >= (blockFirstAsWell ? 0 : 1) && inverse_disableForRinger)
    {
        if (allowAfterAWhile)
        {
            if (hasItBeenAWhile())
            { }
            else
            {
                lastNotificationTime = [[NSDate date] retain];
                return;
            }
        }
        else
        {
            lastNotificationTime = [[NSDate date] retain];
            return;
        }
    }

    %orig;
    lastNotificationTime = [[NSDate date] retain];
}

- (_Bool)shouldPlaySoundForItem:(BBBulletin*)arg1
{
    BOOL ringer = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.ringer"] == FSSwitchStateOn ? YES : NO;
    BOOL inverse_disableForRinger = disableWhenRinger ? !ringer : YES;

    NSMutableArray *li = MSHookIvar<NSMutableArray *>(self, "_listItems");
    if ((([li count] > 1 && disableNoise && enabled) || (enabled && blockFirstAsWell && disableNoise)) && inverse_disableForRinger)
        return NO;
    return %orig;

    /*
    if ([li count] > (blockFirstAsWell ? 0 : 1) && enabled && blockAfterFirstOfEachTitle == NO && disableNoise)
    {
        if (allowAfterAWhile)
        {
            if (hasItBeenAWhile() == NO)
                return NO;
        }
        else
            return NO;
    }

    if (enabled && blockAfterFirstOfEachTitle && getCount([arg1 title]) >= (blockFirstAsWell ? 0 : 1) && disableNoise)
    {
        if (allowAfterAWhile)
        {
            if (hasItBeenAWhile() == NO)
                return NO;
        }
        else
            return NO;
    }

    return %orig;
    */
}

%end

%hook SBLockStateAggregator
-(void)_updateLockState
{
    %orig;
    notifs = [[[NSMutableDictionary alloc] init] retain]; // Clear state
}
%end

%ctor
{
     // Register for the preferences-did-change notification
    CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterAddObserver(r, NULL, &reloadSettings, CFSTR("com.lodc.ios.oon/reloadSettings"), NULL, 0);
    reloadSettings(nil, nil, nil, nil, nil);
}