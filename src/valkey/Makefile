SHELL = /bin/bash
.ONESHELL:
.SHELLFLAGS += -e

VALKEY_VERSION = 5.0.3
VALKEY_VERSION_FULL = $(VALKEY_VERSION)-3~bpo9+2

MAIN_TARGET = valkey-server_$(VALKEY_VERSION_FULL)_$(CONFIGURED_ARCH).deb
DERIVED_TARGETS = valkey-tools_$(VALKEY_VERSION_FULL)_$(CONFIGURED_ARCH).deb \
		  valkey-sentinel_$(VALKEY_VERSION_FULL)_$(CONFIGURED_ARCH).deb \
		  valkey-tools-dbgsym_$(VALKEY_VERSION_FULL)_$(CONFIGURED_ARCH).deb

$(addprefix $(DEST)/, $(MAIN_TARGET)): $(DEST)/% :
	rm -rf  valkey_build
	mkdir valkey_build
	pushd valkey_build

	wget -O valkey_$(VALKEY_VERSION).orig.tar.gz -N "http://http.debian.net/debian/pool/main/v/valkey/valkey_$(VALKEY_VERSION).orig.tar.gz"
	wget -O valkey_$(VALKEY_VERSION_FULL).dsc -N "http://http.debian.net/debian/pool/main/v/valkey/valkey_$(VALKEY_VERSION_FULL).dsc"
	wget -O valkey_$(VALKEY_VERSION_FULL).debian.tar.xz -N "http://http.debian.net/debian/pool/main/v/valkey/valkey_$(VALKEY_VERSION_FULL).debian.tar.xz"
	dpkg-source -x valkey_$(VALKEY_VERSION_FULL).dsc

	pushd valkey-$(VALKEY_VERSION)
	export ARCH=""
ifeq ($(CROSS_BUILD_ENVIRON), y)
	dpkg-buildpackage -us -uc -b -a$(CONFIGURED_ARCH) -Pcross,nocheck -j$(SONIC_CONFIG_MAKE_JOBS) --admindir $(SONIC_DPKG_ADMINDIR)
else
	DEB_BUILD_OPTIONS=nocheck dpkg-buildpackage -us -uc -b -j$(SONIC_CONFIG_MAKE_JOBS) --admindir $(SONIC_DPKG_ADMINDIR)
endif
	popd

	mv $(DERIVED_TARGETS) $* $(DEST)/
	popd

$(addprefix $(DEST)/, $(DERIVED_TARGETS)): $(DEST)/% : $(DEST)/$(MAIN_TARGET)
