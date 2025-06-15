#!/bin/bash

# After the build has finished and after Buildroot has packed the files into selected filesystem images:
# Run image_post.sh
# - prepare the image boot.scr.uimg
# - get sw-version and issue from "${BOARD_ROOT_DIR}/overlay/boot"
# - generate new mountpoints and copy files to this mountpoints
# - the default new mountpoints locate "${BINARIES_DIR}" usually directory "output/images"
#
# Then,run support/scripts/genimage.sh
# - generate the images of each corresponding file system
#
# - generate sdcard image
# - delete some files for compilation
#

source ${BOARD_ROOT_DIR}/scripts/${TARGET_GENERIC_HOSTNAME:?}.config || exit 1

err() {
	if [ "$ERR" ]; then
		echo "$0": "$*" >&2
	fi
}

# u-boot.bin file deal if needed
uboot_deal() {
	[ "${uboot_deal}" != "yes" ] && return 0

	# add IVT, Boot and DCD data to u-boot.bin
	"${BOARD_ROOT_DIR}"/tools/imxdownload ${BINARIES_DIR}/u-boot.bin -512m || return 1
	# rename uboot imx
	mv load.imx ${BINARIES_DIR}/u-boot.imx
}

# generate boot.scr.uimg from boot.scr.cmd
prepare_files() {
	if ! mkimage -C none -A arm -T script -d "${scr_cmd_file}" "${scr_uimg_file}"; then
		err "mkimage ${scr_uimg_file} from ${scr_cmd_file} error"
		return 1
	fi
}

# copy the partition files to the new mount point
# $1: new_mount_points
prepare_fs() {
	# only support cp from ${BINARIES_DIR}
	for point in $1; do
		# clean and mkdir again
		rm -rf "${BINARIES_DIR}/${point}"
		if ! mkdir -p "${BINARIES_DIR}/${point}"; then
			err "failed to create ${point}"
			return 1
		fi

		for files in $(eval "echo \${${point}_files}"); do
			if ! rsync -arH "${BINARIES_DIR}/${files}" "${BINARIES_DIR}/${point}"; then
				err "failed to copy files to ${point}"
				return 1
			fi
		done
	done
}

# generate the images of each corresponding file system
generate_fs() {
	if ! ./support/scripts/genimage.sh -c "${BOARD_ROOT_DIR}/genimage/genimage_images.cfg"; then
		err "failed to generate images"
		return 1
	fi
}

# generate the sdcard image sdcard.img
genimage_sd() {
	# remove old sdcard image
	rm -rf "${BINARIES_DIR}"/*.img

	# generate sdcard.img
	if ! ./support/scripts/genimage.sh -c "${BOARD_ROOT_DIR}/genimage/genimage_sd.cfg"; then
		err "failed to generate sdcard.img"
		return 1
	fi

	rm -rf ${GENIMAGE_CFG}
}

# clean the needless files
clean_files() {
	local files       # the reserve files

	for f in $1; do
		files="${files} -I $f "
	done

	for f in $(ls "${BINARIES_DIR}" ${files}); do
		rm -rf "${BINARIES_DIR:?}/$f"
	done
}

prepare_files || exit 1

if ! uboot_deal; then
	err "uboot deal error"
	exit 1
fi

prepare_fs "${new_mount_points:?}" || exit 1
generate_fs || exit 1

genimage_sd || exit 1
clean_files "${reserved_files:?}"
