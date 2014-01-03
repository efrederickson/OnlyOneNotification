include theos/makefiles/common.mk

ARCHS=armv7 armv7s arm64

TWEAK_NAME = OnlyOneNotification
OnlyOneNotification_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += oonsettings
include $(THEOS_MAKE_PATH)/aggregate.mk
