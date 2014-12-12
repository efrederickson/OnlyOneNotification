#import "FSSwitchDataSource.h"
#import "FSSwitchPanel.h"
#import <notify.h>

@interface OnlyOneNotificationFlipswitchSwitch : NSObject <FSSwitchDataSource>
@end

@interface NSUserDefaults (Private)
- (instancetype)_initWithSuiteName:(NSString *)suiteName container:(NSURL *)container;
@end

@implementation OnlyOneNotificationFlipswitchSwitch

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier
{
	id obj = CFPreferencesCopyAppValue(CFSTR("enabled"), CFSTR("com.lodc.ios.oonsettings"));
	BOOL state = obj ? [obj boolValue] : YES;
    return (state) ? FSSwitchStateOn : FSSwitchStateOff;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier
{
    if (newState == FSSwitchStateIndeterminate)
        return;
    CFBooleanRef newValue = (BOOL)newState ? kCFBooleanTrue : kCFBooleanFalse;
    CFPreferencesSetAppValue ( CFSTR("enabled"), newValue, CFSTR("com.lodc.ios.oonsettings") );
    notify_post("com.lodc.ios.oon/reloadSettings");
}

@end
