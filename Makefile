ARCHS = armv7 arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AVLock
AVLock_FILES = Tweak.xm
AVLock_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk


BUNDLE_NAME = AVLockBundle
AVLockBundle_INSTALL_PATH = /Library/Application Support
include $(THEOS)/makefiles/bundle.mk

after-install::
	install.exec "killall -9 SpringBoard"
