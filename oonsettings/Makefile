include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = OONSettings
OONSettings_FILES = OONSettings.mm
OONSettings_INSTALL_PATH = /Library/PreferenceBundles
OONSettings_FRAMEWORKS = UIKit
OONSettings_PRIVATE_FRAMEWORKS = Preferences

ARCHS = armv7 armv7s arm64

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/OONSettings.plist$(ECHO_END)
