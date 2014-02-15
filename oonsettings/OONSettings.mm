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
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=mlnlover11"]];
}

-(void) openGithub
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"github.com/mlnlover11"]];
}

-(void) sendEmail
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:elijah.frederickson@gmail.com?subject=OnlyOneNotification"]];
}

-(void) donatePaypal
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=6ZLWPUSTR7XLQ&lc=US&item_name=OnlyOneNotification%20Donations&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted"]];
    
}

-(void) donateBitcoin
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://coinbase.com/checkouts/9066da6836ac005ad852734fa3567288"]];
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
