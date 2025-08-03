################################################################################
#
# frp
#
################################################################################

FRP_VERSION = 0.44.0
FRP_SITE = $(call github,fatedier,frp,v$(FRP_VERSION))

FRP_LICENSE = Apache-2.0
FRP_LICENSE_FILES = LICENSE

FRP_DEPENDENCIES = host-go

FRP_BUILD_TARGETS = cmd/frpc cmd/frps
FRP_INSTALL_BINS = $(notdir $(FRP_BUILD_TARGETS))

define FRP_INSTALL_CONFIG_FILES
	$(INSTALL) -D -m 0644 $(@D)/conf/frpc.ini $(TARGET_DIR)/etc/frp/frpc.ini
	$(INSTALL) -D -m 0644 $(@D)/conf/frps.ini $(TARGET_DIR)/etc/frp/frps.ini
endef

FRP_POST_INSTALL_TARGET_HOOKS += FRP_INSTALL_CONFIG_FILES

$(eval $(golang-package))
