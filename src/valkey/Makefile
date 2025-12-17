SHELL = /bin/bash
.ONESHELL:
.SHELLFLAGS += -e

VALKEY_VERSION = 8.0.1
VALKEY_VERSION_FULL = $(VALKEY_VERSION)-1

MAIN_TARGET = valkey-server_$(VALKEY_VERSION_FULL)_$(CONFIGURED_ARCH).deb
DERIVED_TARGETS = valkey-tools_$(VALKEY_VERSION_FULL)_$(CONFIGURED_ARCH).deb \
		  valkey-sentinel_$(VALKEY_VERSION_FULL)_$(CONFIGURED_ARCH).deb \
		  valkey-tools-dbgsym_$(VALKEY_VERSION_FULL)_$(CONFIGURED_ARCH).deb

$(addprefix $(DEST)/, $(MAIN_TARGET)): $(DEST)/% :
	rm -rf valkey_build
	mkdir valkey_build
	pushd valkey_build

	# Download Valkey source from GitHub releases
	wget -O valkey-$(VALKEY_VERSION).tar.gz -N "https://github.com/valkey-io/valkey/archive/refs/tags/$(VALKEY_VERSION).tar.gz"
	tar xzf valkey-$(VALKEY_VERSION).tar.gz
	
	pushd valkey-$(VALKEY_VERSION)
	
	# Build Valkey
	make -j$(SONIC_CONFIG_MAKE_JOBS) PREFIX=/usr
	
	# Create debian package structure
	mkdir -p debian/valkey-server/usr/bin
	mkdir -p debian/valkey-server/etc/valkey
	mkdir -p debian/valkey-server/var/lib/valkey
	mkdir -p debian/valkey-server/var/run/valkey
	mkdir -p debian/valkey-server/DEBIAN
	
	mkdir -p debian/valkey-tools/usr/bin
	mkdir -p debian/valkey-tools/DEBIAN
	
	mkdir -p debian/valkey-sentinel/usr/bin
	mkdir -p debian/valkey-sentinel/etc/valkey
	mkdir -p debian/valkey-sentinel/DEBIAN
	
	# Install binaries
	cp src/valkey-server debian/valkey-server/usr/bin/
	cp src/valkey-cli debian/valkey-tools/usr/bin/
	cp src/valkey-benchmark debian/valkey-tools/usr/bin/
	cp src/valkey-sentinel debian/valkey-sentinel/usr/bin/
	
	# Create Redis compatibility symlinks
	ln -sf valkey-server debian/valkey-server/usr/bin/redis-server
	ln -sf valkey-cli debian/valkey-tools/usr/bin/redis-cli
	ln -sf valkey-benchmark debian/valkey-tools/usr/bin/redis-benchmark
	ln -sf valkey-sentinel debian/valkey-sentinel/usr/bin/redis-sentinel
	
	# Create config directory symlink for compatibility
	mkdir -p debian/valkey-server/etc/redis
	
	# Copy default config
	cp valkey.conf debian/valkey-server/etc/valkey/
	cp sentinel.conf debian/valkey-sentinel/etc/valkey/
	
	# Create symlinks for redis config compatibility
	ln -sf /etc/valkey/valkey.conf debian/valkey-server/etc/redis/redis.conf
	
	# Create control files
	echo "Package: valkey-server" > debian/valkey-server/DEBIAN/control
	echo "Version: $(VALKEY_VERSION_FULL)" >> debian/valkey-server/DEBIAN/control
	echo "Architecture: $(CONFIGURED_ARCH)" >> debian/valkey-server/DEBIAN/control
	echo "Maintainer: SONiC Team" >> debian/valkey-server/DEBIAN/control
	echo "Depends: valkey-tools" >> debian/valkey-server/DEBIAN/control
	echo "Provides: redis-server" >> debian/valkey-server/DEBIAN/control
	echo "Conflicts: redis-server" >> debian/valkey-server/DEBIAN/control
	echo "Replaces: redis-server" >> debian/valkey-server/DEBIAN/control
	echo "Description: Valkey server - Redis-compatible in-memory data store" >> debian/valkey-server/DEBIAN/control
	
	echo "Package: valkey-tools" > debian/valkey-tools/DEBIAN/control
	echo "Version: $(VALKEY_VERSION_FULL)" >> debian/valkey-tools/DEBIAN/control
	echo "Architecture: $(CONFIGURED_ARCH)" >> debian/valkey-tools/DEBIAN/control
	echo "Maintainer: SONiC Team" >> debian/valkey-tools/DEBIAN/control
	echo "Provides: redis-tools" >> debian/valkey-tools/DEBIAN/control
	echo "Conflicts: redis-tools" >> debian/valkey-tools/DEBIAN/control
	echo "Replaces: redis-tools" >> debian/valkey-tools/DEBIAN/control
	echo "Description: Valkey tools - Redis-compatible CLI and utilities" >> debian/valkey-tools/DEBIAN/control
	
	echo "Package: valkey-sentinel" > debian/valkey-sentinel/DEBIAN/control
	echo "Version: $(VALKEY_VERSION_FULL)" >> debian/valkey-sentinel/DEBIAN/control
	echo "Architecture: $(CONFIGURED_ARCH)" >> debian/valkey-sentinel/DEBIAN/control
	echo "Maintainer: SONiC Team" >> debian/valkey-sentinel/DEBIAN/control
	echo "Depends: valkey-server" >> debian/valkey-sentinel/DEBIAN/control
	echo "Provides: redis-sentinel" >> debian/valkey-sentinel/DEBIAN/control
	echo "Conflicts: redis-sentinel" >> debian/valkey-sentinel/DEBIAN/control
	echo "Replaces: redis-sentinel" >> debian/valkey-sentinel/DEBIAN/control
	echo "Description: Valkey sentinel - Redis-compatible high availability" >> debian/valkey-sentinel/DEBIAN/control
	
	# Build packages
	dpkg-deb --build debian/valkey-server
	dpkg-deb --build debian/valkey-tools
	dpkg-deb --build debian/valkey-sentinel
	
	# Rename to proper names
	mv debian/valkey-server.deb ../valkey-server_$(VALKEY_VERSION_FULL)_$(CONFIGURED_ARCH).deb
	mv debian/valkey-tools.deb ../valkey-tools_$(VALKEY_VERSION_FULL)_$(CONFIGURED_ARCH).deb
	mv debian/valkey-sentinel.deb ../valkey-sentinel_$(VALKEY_VERSION_FULL)_$(CONFIGURED_ARCH).deb
	
	popd

	mv $(DERIVED_TARGETS) $* $(DEST)/
	popd

$(addprefix $(DEST)/, $(DERIVED_TARGETS)): $(DEST)/% : $(DEST)/$(MAIN_TARGET)
