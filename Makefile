#
# Dominic Allan
#
# This is free software, licensed under the GNU General Public License v2.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=libwebsockets
PKG_VERSION:=1.23
PKG_RELEASE:=1

SOURCE_URL=https://github.com/warmcat/libwebsockets/archive/
SRC=v1.23-chrome32-firefox24.tar.gz
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/libwebsockets
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=libwebsockets
	DEPENDS:=+zlib
endef

define Build/Prepare
	-rm -rf src
	mkdir -p $(PKG_BUILD_DIR)
	wget $(SOURCE_URL)$(SRC) && tar -zxvf $(SRC)
	mv libwebsockets-1.23-chrome32-firefox24 src
	patch -d src -p1 < 001.patch
	rm -rf $(SRC)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
	rm -f $(PKG_BUILD_DIR)/CMakeCache.txt
	rm -fR $(PKG_BUILD_DIR)/CMakeFiles
	rm -f $(PKG_BUILD_DIR)/Makefile ]
	rm -f $(PKG_BUILD_DIR)/cmake_install.cmake
	rm -f $(PKG_BUILD_DIR)/progress.make
#	rm -f $(PKG_BUILD_DIR)/shared-lib/CMakeCache.txt
#	rm -fR $(PKG_BUILD_DIR)/shared-lib/CMakeFiles
#	rm -f $(PKG_BUILD_DIR)/shared-lib/Makefile ]
#	rm -f $(PKG_BUILD_DIR)/shared-lib/cmake_install.cmake
#	rm -f $(PKG_BUILD_DIR)/shared-lib/progress.make
#	rm -f $(PKG_BUILD_DIR)/static-lib/CMakeCache.txt
#	rm -fR $(PKG_BUILD_DIR)/static-lib/CMakeFiles
#	rm -f $(PKG_BUILD_DIR)/static-lib/Makefile ]
#	rm -f $(PKG_BUILD_DIR)/static-lib/cmake_install.cmake
#	rm -f $(PKG_BUILD_DIR)/static-lib/progress.make
endef

define Build/Configure
  IN_OPENWRT=1 \
  AR="$(TOOLCHAIN_DIR)/bin/$(TARGET_CROSS)ar" \
  AS="$(TOOLCHAIN_DIR)/bin/$(TARGET_CC) -c $(TARGET_CFLAGS)" \
  LD="$(TOOLCHAIN_DIR)/bin/$(TARGET_CROSS)ld" \
  NM="$(TOOLCHAIN_DIR)/bin/$(TARGET_CROSS)nm" \
  CC="$(TOOLCHAIN_DIR)/bin/$(TARGET_CC)" \
  GCC="$(TOOLCHAIN_DIR)/bin/$(TARGET_CC)" \
  CXX="$(TOOLCHAIN_DIR)/bin/$(TARGET_CROSS)g++" \
  RANLIB="$(TOOLCHAIN_DIR)/bin/$(TARGET_CROSS)ranlib" \
  STRIP="$(TOOLCHAIN_DIR)/bin/$(TARGET_CROSS)strip" \
  OBJCOPY="$(TOOLCHAIN_DIR)/bin/$(TARGET_CROSS)objcopy" \
	OBJDUMP="$(TOOLCHAIN_DIR)/bin/$(TARGET_CROSS)objdump" \
	TARGET_CPPFLAGS="$(TARGET_CPPFLAGS)" \
	TARGET_CFLAGS="$(TARGET_CFLAGS)" \
	TARGET_LDFLAGS="$(TARGET_LDFLAGS)" \
	cmake -DWITH_SSL=0 $(PKG_BUILD_DIR)/CMakeLists.txt -DWITHOUT_EXTENSIONS=1 
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR)/usr/include/libwebsockets
	$(CP) $(PKG_BUILD_DIR)/lib/*.h $(STAGING_DIR)/usr/include/
	$(INSTALL_DIR) $(STAGING_DIR)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/lib/libwebsockets.so* $(STAGING_DIR)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/lib/libwebsockets.a $(STAGING_DIR)/usr/lib/
endef

define Build/UninstallDev
	rm -rf \
	$(STAGING_DIR)/usr/include/libwebsockets.h \
	$(STAGING_DIR)/usr/lib/libwebsockets.so* \
	$(STAGING_DIR)/usr/lib/libwebsockets.a
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)
endef

define Package/libwebsockets/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lib/libwebsockets.so* $(1)/usr/lib/
# Comment out these lines below to install libwebsockets test-server demo
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/* $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/local/share/libwebsockets-test-server
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/test-server/* $(1)/usr/local/share/libwebsockets-test-server
	rm $(1)/usr/local/share/libwebsockets-test-server/*.c
endef


$(eval $(call BuildPackage,libwebsockets))

