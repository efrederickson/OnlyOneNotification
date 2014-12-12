ARCHS = armv7 armv7s arm64
TARGET = iphone:clang:latest:latest

include theos/makefiles/common.mk

TWEAK_NAME = OnlyOneNotification
OnlyOneNotification_FILES = Tweak.xm
OnlyOneNotification_LIBRARIES = flipswitch

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += oonsettings
SUBPROJECTS += onlyonenotificationflipswitch
include $(THEOS_MAKE_PATH)/aggregate.mk
