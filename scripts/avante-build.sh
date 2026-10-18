#!/usr/bin/env bash
# Build avante.nvim's native (Rust) libraries, resiliently.
#
# avante ships `make BUILD_FROM_SOURCE=true`, which on macOS is broken at some
# commits: it runs
#     cargo build --release ... -p avante-<crate>
#     cp target/release/libavante_<crate>.so lua/avante_<crate>.so
# but cargo emits .dylib on macOS, so the copy fails. The build then exits
# non-zero having left whatever lua/*.so were already there — stale libraries
# paired with freshly checked-out Lua code. Loading that mismatch does not raise
# a Lua error: the kernel SIGKILLs nvim, so it appears to close itself the
# instant it opens, with nothing in :messages.
#
# So: try avante's own Makefile first (it is correct on Linux, and on avante
# commits that have fixed this), and only if it fails do the build here and copy
# whichever extension cargo actually produced.
#
# lazy.nvim runs `build` with the working directory set to the plugin's own
# directory, so the relative paths below are correct.
set -uo pipefail

LUA_VERSION="${LUA_VERSION:-luajit}"

# The three libraries avante's Lua side requires (`require("avante_tokenizers")`
# and friends). html2md is deliberately omitted: avante does not load it, and
# cargo names it libhtml2md rather than libavante_html2md.
CRATES=(tokenizers templates repo-map)

if make BUILD_FROM_SOURCE=true; then
	exit 0
fi

echo "avante-build: avante's Makefile failed — building and installing directly" >&2

for crate in "${CRATES[@]}"; do
	if ! cargo build --release --features="$LUA_VERSION" -p "avante-$crate"; then
		echo "avante-build: cargo failed for avante-$crate" >&2
		exit 1
	fi
done

mkdir -p lua
status=0

for crate in "${CRATES[@]}"; do
	lib="avante_${crate//-/_}"
	src=""
	for ext in dylib so; do
		if [[ -f "target/release/lib${lib}.${ext}" ]]; then
			src="target/release/lib${lib}.${ext}"
			break
		fi
	done

	if [[ -z "$src" ]]; then
		echo "avante-build: no built library found for avante-$crate" >&2
		status=1
		continue
	fi

	# nvim finds .so on the runtimepath regardless of the real object format.
	cp -f "$src" "lua/${lib}.so"

	# Replacing a signed library in place leaves a stale signature, which macOS
	# answers by killing the loading process. Re-sign ad-hoc so that cannot bite.
	if [[ "$(uname)" == "Darwin" ]]; then
		codesign --force --sign - "lua/${lib}.so" >/dev/null 2>&1 ||
			echo "avante-build: warning — could not re-sign lua/${lib}.so" >&2
	fi

	echo "avante-build: installed lua/${lib}.so from ${src}" >&2
done

exit $status
