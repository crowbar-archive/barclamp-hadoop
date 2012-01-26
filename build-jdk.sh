#!/bin/bash
ORACLE_JAVA_RPMS=(jdk-6u27-linux-amd64.rpm)

bc_needs_build() {
    for pkg in ${ORACLE_JAVA_RPMS[@]}; do
	[[ -f $BC_CACHE/$OS_TOKEN/pkgs/$pkg ]] && continue
	return 0
    done
    return 1
}

bc_build() {
    sudo cp "$BC_DIR/build_jdk_in_chroot.sh" "$CHROOT/tmp"
    in_chroot /tmp/build_jdk_in_chroot.sh
    local pkg
    for pkg in "${ORACLE_JAVA_RPMS[@]}"; do
	[[ -f $BC_CACHE/$OS_TOKEN/pkgs/$pkg ]] || \
	    die "Hadoop build process did not build $pkg!"
	if [[ $CURRENT_CACHE_BRANCH ]]; then
	    (cd "$BC_CACHE/$OS_TOKEN/pkgs"; git add "$pkg")
	fi
    done
}
