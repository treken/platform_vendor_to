PRODUCT_VERSION_MAJOR = 1
PRODUCT_VERSION_MINOR = 0
PRODUCT_VERSION_MAINTENANCE = ALPHA

# Set TO_BUILDTYPE from the env RELEASE_TYPE, for jenkins compat

ifndef TO_BUILDTYPE
    ifdef RELEASE_TYPE
        # Starting with "TO_" is optional
        RELEASE_TYPE := $(shell echo $(RELEASE_TYPE) | sed -e 's|^TO_||g')
        TO_BUILDTYPE := $(RELEASE_TYPE)
    endif
endif

# Filter out random types, so it'll reset to UNOFFICIAL
ifeq ($(filter RELEASE NIGHTLY SNAPSHOT EXPERIMENTAL,$(TO_BUILDTYPE)),)
    TO_BUILDTYPE :=
endif

ifdef TO_BUILDTYPE
    ifneq ($(TO_BUILDTYPE), SNAPSHOT)
        ifdef TO_EXTRAVERSION
            # Force build type to EXPERIMENTAL
            TO_BUILDTYPE := EXPERIMENTAL
            # Remove leading dash from TO_EXTRAVERSION
            TO_EXTRAVERSION := $(shell echo $(TO_EXTRAVERSION) | sed 's/-//')
            # Add leading dash to TO_EXTRAVERSION
            TO_EXTRAVERSION := -$(TO_EXTRAVERSION)
        endif
    else
        ifndef TO_EXTRAVERSION
            # Force build type to EXPERIMENTAL, SNAPSHOT mandates a tag
            TO_BUILDTYPE := EXPERIMENTAL
        else
            # Remove leading dash from TO_EXTRAVERSION
            TO_EXTRAVERSION := $(shell echo $(TO_EXTRAVERSION) | sed 's/-//')
            # Add leading dash to TO_EXTRAVERSION
            TO_EXTRAVERSION := -$(TO_EXTRAVERSION)
        endif
    endif
else
    # If TO_BUILDTYPE is not defined, set to UNOFFICIAL
    TO_BUILDTYPE := RELEASE
    TO_EXTRAVERSION :=
endif

ifeq ($(TO_BUILDTYPE), UNOFFICIAL)
    ifneq ($(TARGET_UNOFFICIAL_BUILD_ID),)
        TO_EXTRAVERSION := -$(TARGET_UNOFFICIAL_BUILD_ID)
    endif
endif

ifeq ($(TO_BUILDTYPE), RELEASE)
    ifndef TARGET_VENDOR_RELEASE_BUILD_ID
        TO_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE)$(PRODUCT_VERSION_DEVICE_SPECIFIC)-$(TO_BUILD)
    else
        ifeq ($(TARGET_BUILD_VARIANT),user)
            TO_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(TARGET_VENDOR_RELEASE_BUILD_ID)-$(TO_BUILD)
        else
            TO_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE)$(PRODUCT_VERSION_DEVICE_SPECIFIC)-$(TO_BUILD)
        endif
    endif
else
    ifeq ($(PRODUCT_VERSION_MINOR),0)
        TO_VERSION := $(PRODUCT_VERSION_MAJOR)-$(shell date -u +%Y%m%d)-$(TO_BUILDTYPE)$(TO_EXTRAVERSION)-$(TO_BUILD)
    else
        TO_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(shell date -u +%Y%m%d)-$(TO_BUILDTYPE)$(TO_EXTRAVERSION)-$(TO_BUILD)
    endif
endif

PRODUCT_PROPERTY_OVERRIDES += \
  ro.to.version=$(TO_VERSION) \
  ro.to.releasetype=$(TO_BUILDTYPE) \
  ro.modversion=$(TO_VERSION) \
#  ro.cmlegal.url=http://www.cyanogenmod.org/docs/privacy

-include vendor/cm-priv/keys/keys.mk

TO_DISPLAY_VERSION := $(TO_VERSION)

ifneq ($(PRODUCT_DEFAULT_DEV_CERTIFICATE),)
ifneq ($(PRODUCT_DEFAULT_DEV_CERTIFICATE),build/target/product/security/testkey)
  ifneq ($(TO_BUILDTYPE), UNOFFICIAL)
    ifndef TARGET_VENDOR_RELEASE_BUILD_ID
      ifneq ($(TO_EXTRAVERSION),)
        # Remove leading dash from TO_EXTRAVERSION
        TO_EXTRAVERSION := $(shell echo $(TO_EXTRAVERSION) | sed 's/-//')
        TARGET_VENDOR_RELEASE_BUILD_ID := $(TO_EXTRAVERSION)
      else
        TARGET_VENDOR_RELEASE_BUILD_ID := $(shell date -u +%Y%m%d)
      endif
    else
      TARGET_VENDOR_RELEASE_BUILD_ID := $(TARGET_VENDOR_RELEASE_BUILD_ID)
    endif
    TO_DISPLAY_VERSION=$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(TARGET_VENDOR_RELEASE_BUILD_ID)
  endif
endif
endif
