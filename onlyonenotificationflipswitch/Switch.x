#import "FSSwitchDataSource.h"
#import "FSSwitchPanel.h"

@interface OnlyOneNotificationFlipswitchSwitch : NSObject <FSSwitchDataSource>
@end

@implementation OnlyOneNotificationFlipswitchSwitch

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier
{
    NSDictionary *prefs = [NSDictionary 
        dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.lodc.ios.oonsettings.plist"];
    if ([prefs objectForKey:@"enabled"] != nil)
        return [[prefs objectForKey:@"enabled"] boolValue] ? FSSwitchStateOn : FSSwitchStateOff;
    else
        return FSSwitchStateOn;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier
{
    if (newState == FSSwitchStateIndeterminate)
        return;
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.lodc.ios.oonsettings.plist"];
    [prefs setObject:[NSNumber numberWithBool:YES] forKey:@"enabled"];
    [prefs writeToFile:@"/var/mobile/Library/Preferences/com.lodc.ios.oonsettings.plist" atomically:YES];
}

@end