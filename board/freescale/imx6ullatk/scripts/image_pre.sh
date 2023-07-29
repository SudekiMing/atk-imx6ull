#!/bin/bash

# As genimage only supports vfat uses key "files".
# The ext4 image should uses key "mountpoint" to copy files to ext4 image.
# As a result, buildroot rootfs and ext4 image both contain the same files.
#
# A possible solution is:
# - patch support/scripts/genimage.sh to allow other rootpaths to be used
# - support/scripts/genimage.sh default uses buildroot "${TARGET_DIR}" as rootpaths
#
# After build has finished and before buildroot starts packing the files into selected filesystem images
# Run image_pre.sh
# - generate all used image from "${TARGET_DIR}" to "${BINARIES_DIR}"
# - generate extra_images from "${BOARD_ROOT_DIR}" to "${BINARIES_DIR}"
# - avoid buildroot rootfs contains the same files, remove these files on rootfs
#

source ${BOARD_ROOT_DIR}/scripts/${TARGET_GENERIC_HOSTNAME:?}.config || exit 1

err() {
	if [ "$ERR" ]; then
		echo "$0": "$*" >&2
	fi
}

notice() {
	if [ "$NOTICE" ]; then
		echo "$0": "$*" >&1
	fi
}

# install the files in boot,vendor,root,usr/local and extra_images to output/images
# $1: rootfs_mount_points,the files to generate images
prepare_files() {
	for point in $1; do
		notice "points: ${TARGET_DIR}/${point}"
		if ! rsync -arH "${TARGET_DIR}/${point}/" "${BINARIES_DIR}"; then
			err "failed to install the files of ${point}"
			return 1
		fi
		rm -rf "${TARGET_DIR:?}/${point}"/*
	done

	if [ -d "${BOARD_ROOT_DIR}/extra_images" ]; then
		notice "install extra images to ${BINARIES_DIR}"
		if ! rsync -arHL "${BOARD_ROOT_DIR}/extra_images/" "${BINARIES_DIR}"; then
			err "failed to install extra images to ${BINARIES_DIR}"
			return 1
		fi
		notice "install extra images to ${BINARIES_DIR} success"
	fi
}

prepare_files "${rootfs_mount_points:?}" || exit 1
