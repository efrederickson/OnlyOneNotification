#import <Preferences/Preferences.h>

@interface OONSettingsListController: PSListController {
}
@end

@implementation OONSettingsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"OONSettings" target:self] retain];
	}
	return _specifiers;
}

-(void) openTwitter
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=daementor"]];
}

-(void) openGithub
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"github.com/mlnlover11"]];
}

-(void) sendEmail
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:elijah.frederickson@gmail.com?subject=OnlyOneNotification"]];
}
@end

@interface OONHelpListController: PSListController {
}
@end

@implementation OONHelpListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"OONHelp" target:self] retain];
	}
	return _specifiers;
}
@end

// vim:ft=objc
