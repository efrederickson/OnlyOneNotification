#import <substrate.h>

static BOOL enabled = YES;
static BOOL disableNoise = YES;
static BOOL disableAllNotifications = YES;

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

    if ([prefs objectForKey:@"disableAllNotifications"] != nil)    
        disableAllNotifications = [[prefs objectForKey:@"disableAllNotifications"] boolValue];
    else
        disableAllNotifications = NO;

    NSLog(@"OnlyOneNotification: preferences updated");
    //NSLog(@"OnlyOneNotification: DisableAll, disableNoise: %@ , %@", disableAllNotifications ? @"yes" : @"no", disableNoise ? @"yes" : @"no");
}

%hook SBLockScreenNotificationListController

- (void)turnOnScreenIfNecessaryForItem:(id)arg1
{
    NSMutableArray *li = MSHookIvar<NSMutableArray *>(self, "_listItems");
    if (([li count] > 1 && enabled) || (enabled && disableAllNotifications))
        return;
    %orig;
}

- (_Bool)shouldPlaySoundForItem:(id)arg1
{
    NSMutableArray *li = MSHookIvar<NSMutableArray *>(self, "_listItems");
    if (([li count] > 1 && disableNoise && enabled) || (enabled && disableAllNotifications && disableNoise))
        return NO;
    return %orig;
}

%end

%ctor
{
     // Register for the preferences-did-change notification
    CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterAddObserver(r, NULL, &reloadSettings, CFSTR("com.lodc.ios.oon/reloadSettings"), NULL, 0);
}