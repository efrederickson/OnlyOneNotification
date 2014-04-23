THEOS_DEVICE_IP = 192.168.7.146
THEOS_DEVICE_PORT = 22

include theos/makefiles/common.mk

ARCHS=armv7 armv7s arm64

TWEAK_NAME = OnlyOneNotification
OnlyOneNotification_FILES = Tweak.xm
OnlyOneNotification_LIBRARIES = flipswitch

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += oonsettings
SUBPROJECTS += onlyonenotificationflipswitch
include $(THEOS_MAKE_PATH)/aggregate.mk
