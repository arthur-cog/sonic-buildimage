# valkey package (replacement for redis)
# Valkey is a Redis fork that is API-compatible

VALKEY_VERSION = 8.0.1-1

VALKEY_TOOLS = valkey-tools_$(VALKEY_VERSION)_$(CONFIGURED_ARCH).deb
$(VALKEY_TOOLS)_SRC_PATH = $(SRC_PATH)/valkey
SONIC_MAKE_DEBS += $(VALKEY_TOOLS)

VALKEY_TOOLS_DBG = valkey-tools-dbgsym_$(VALKEY_VERSION)_$(CONFIGURED_ARCH).deb
$(eval $(call add_derived_package,$(VALKEY_TOOLS),$(VALKEY_TOOLS_DBG)))

VALKEY_SERVER = valkey-server_$(VALKEY_VERSION)_$(CONFIGURED_ARCH).deb
$(eval $(call add_derived_package,$(VALKEY_TOOLS),$(VALKEY_SERVER)))

VALKEY_SENTINEL = valkey-sentinel_$(VALKEY_VERSION)_$(CONFIGURED_ARCH).deb
$(VALKEY_SENTINEL)_DEPENDS += $(VALKEY_SERVER)
$(VALKEY_SENTINEL)_RDEPENDS += $(VALKEY_SERVER)
$(eval $(call add_derived_package,$(VALKEY_TOOLS),$(VALKEY_SENTINEL)))

# The .c, .cpp, .h & .hpp files under src/{$DBG_SRC_ARCHIVE list}
# are archived into debug one image to facilitate debugging.
#
DBG_SRC_ARCHIVE += valkey

# For backward compatibility, also export redis-compatible names
# These will be provided by valkey packages with compatibility symlinks
REDIS_TOOLS = $(VALKEY_TOOLS)
REDIS_SERVER = $(VALKEY_SERVER)
REDIS_SENTINEL = $(VALKEY_SENTINEL)
