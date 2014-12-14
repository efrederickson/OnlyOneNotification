ARCHS = armv7 armv7s arm64
CFLAGS = -fobjc-arc
TARGET = iphone:clang:latest:latest

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = OnlyOneNotification
OnlyOneNotification_FILES = Tweak.xm
#OnlyOneNotification_LIBRARIES = flipswitch
OnlyOneNotification_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += oonsettings
SUBPROJECTS += onlyonenotificationflipswitch
include $(THEOS_MAKE_PATH)/aggregate.mk
