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
@end

// vim:ft=objc
