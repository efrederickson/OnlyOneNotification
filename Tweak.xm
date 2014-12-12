#import <substrate.h>
#import "onlyonenotificationflipswitch/FSSwitchDataSource.h"
#import "onlyonenotificationflipswitch/FSSwitchPanel.h"
#import "onlyonenotificationflipswitch/FSSwitchState.h"
#import "BBBulletin.h"

#define DEBUG
#ifdef DEBUG
#define DebugLog(fmt, ...) NSLog((@"[OnlyOneNotification] " fmt), ##__VA_ARGS__)
#else
#define DebugLog(s, ...)
#endif
#define IS_OS_8_OR_HIGHER (UIDevice.currentDevice.systemVersion.floatValue >= 8.0)

static NSDictionary *prefs;
static BOOL enabled = YES;
static BOOL disableNoise = YES;
static BOOL blockFirstAsWell = YES;
static NSMutableDictionary *notifs = [[NSMutableDictionary alloc] init];
static BOOL blockAfterFirstOfEachTitle = YES;
static BOOL allowAfterAWhile = YES;
static NSDate *lastNotificationTime = nil;
static BOOL disableWhenRinger = NO;
static BOOL onlyReEnableNoise = YES;
static int timeToWait;
static NSMutableDictionary *blacklistedApps = [[NSMutableDictionary alloc] init];

static void reloadSettings(CFNotificationCenterRef center,
                                    void *observer,
                                    CFStringRef name,
                                    const void *object,
                                    CFDictionaryRef userInfo)
{
    prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.lodc.ios.oonsettings.plist"];
    NSArray *keys = [prefs allKeys];
    for (NSString *key in keys) {
        if ([key hasPrefix:@"blacklisted-"]) {
            NSString *bundleID = [key substringFromIndex:12];
            [blacklistedApps setObject:[prefs objectForKey:key] forKey:bundleID];
        }
    }
    
    if (IS_OS_8_OR_HIGHER) { //CFPreferences should work on <iOS 8, but in my experience, it hasn't, so we'll stick with the preference plist.
        CFStringRef appID = CFSTR("com.lodc.ios.oonsettings");
        CFArrayRef keyList = CFPreferencesCopyKeyList(appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
        if (!keyList) {
            DebugLog(@"There's been an error getting the key list!");
            return;
        }
        prefs = (NSDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
    }
    
    id obj = [prefs objectForKey:@"enabled"];
    enabled = obj ? [obj boolValue] : YES;
    DebugLog(@"enabled = %d", enabled);
 
    obj = [prefs objectForKey:@"disableNoise"];
    disableNoise = obj ? [obj boolValue] : YES;
    DebugLog(@"disableNoise = %d", disableNoise);
    
    obj = [prefs objectForKey:@"blockFirstAsWell"];
    blockFirstAsWell = [obj boolValue];
    DebugLog(@"blockFirstAsWell = %d", blockFirstAsWell);

    obj = [prefs objectForKey:@"blockAfterFirstOfEachTitle"];
    blockAfterFirstOfEachTitle = obj ? [obj boolValue] : YES;
    DebugLog(@"blockAfterFirstOfEachTitle = %d", blockAfterFirstOfEachTitle);

    obj = [prefs objectForKey:@"allowAfterAWhile"];
    allowAfterAWhile = obj ? [obj boolValue] : YES;
    DebugLog(@"allowAfterAWhile = %d", allowAfterAWhile);

    obj = [prefs objectForKey:@"disableWhenRinger"];
    disableWhenRinger = [obj boolValue];
    DebugLog(@"disableWhenRinger = %d", disableWhenRinger);

    obj = [prefs objectForKey:@"onlyReEnableNoise"];
    onlyReEnableNoise = obj ? [obj boolValue] : YES;
    DebugLog(@"onlyReEnableNoise = %d", onlyReEnableNoise);
    
    timeToWait = [[prefs objectForKey:@"timeToWait"] intValue] ?: 90;
    DebugLog(@"timeToWait = %d", timeToWait);
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

%hook SBLockScreenNotificationListController

- (void)turnOnScreenIfNecessaryForItem:(BBBulletin*)arg1
{
    NSMutableArray *li = MSHookIvar<NSMutableArray *>(self, "_listItems");

    BOOL sectionIDOkay = ![[blacklistedApps objectForKey:[arg1 sectionID]] boolValue];
    BOOL ringer = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.ringer"] == FSSwitchStateOn ? YES : NO;
    BOOL inverse_disableForRinger = disableWhenRinger ? !ringer : YES;
    inverse_disableForRinger = onlyReEnableNoise ? YES : inverse_disableForRinger;
    if ([li count] > (blockFirstAsWell ? 0 : 1) && enabled && !blockAfterFirstOfEachTitle && inverse_disableForRinger && sectionIDOkay)
    {
        DebugLog(@"We got in the first screen test");
        if (allowAfterAWhile)
        {
            if (hasItBeenAWhile())
            { }
            else
            {
                lastNotificationTime = [NSDate date];
                return;
            }
        }
        else
        {
            lastNotificationTime = [NSDate date];
            return;
        }
    }

    if (enabled && blockAfterFirstOfEachTitle && updateCount([arg1 title]) >= (blockFirstAsWell ? 0 : 1) && inverse_disableForRinger && sectionIDOkay)
    {
        DebugLog(@"We got in the second screen test");
        if (allowAfterAWhile)
        {
            if (hasItBeenAWhile())
            { }
            else
            {
                lastNotificationTime = [NSDate date];
                return;
            }
        }
        else
        {
            lastNotificationTime = [NSDate date];
            return;
        }
    }

    %orig;
    lastNotificationTime = [NSDate date];
}

- (_Bool)shouldPlaySoundForItem:(BBBulletin*)arg1
{
    BOOL sectionIDOkay = ![[blacklistedApps objectForKey:[arg1 sectionID]] boolValue];
    BOOL ringer = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.ringer"] == FSSwitchStateOn ? YES : NO;
    BOOL inverse_disableForRinger = disableWhenRinger ? !ringer : YES;

    NSMutableArray *li = MSHookIvar<NSMutableArray *>(self, "_listItems");
    if ((([li count] > 1 && disableNoise && enabled) || (enabled && blockFirstAsWell && disableNoise)) && inverse_disableForRinger && sectionIDOkay)
        return NO;
    return %orig;
}

%end

%hook SBLockStateAggregator
-(void)_updateLockState
{
    %orig;
    notifs = [NSMutableDictionary dictionary]; // Clear state
}
%end

%ctor
{
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &reloadSettings, CFSTR("com.lodc.ios.oon/reloadSettings"), NULL, 0);
    reloadSettings(nil, nil, nil, nil, nil);
}