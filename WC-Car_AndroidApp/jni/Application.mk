APP_BUILD_SCRIPT = Android.mk
APP_PLATFORM := android-9
APP_CPPFLAGS += -fno-rtti
APP_CPPFLAGS += -lsupc++
#APP_CPPFLAGS += -lgnustl_static
APP_ABI := armeabi
#APP_STL := gnustl_static
#APP_STL := stlport_static
APP_STL := stlport_shared

