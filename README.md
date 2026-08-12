# TWRP recovery tree — Samsung Galaxy J3 2017 (J330F/FN/G, codename j3y17lte)

This is **not an original AOSP/TWRP source tree**.

The original builder never published the device tree for this recovery. The release thread only ever said "DEVICE TREE: soon", and that tree never showed up. What this repo does instead is tear down the released, working `recovery.img` and put the useful pieces somewhere they can actually be reused.

That means the fstab, kernel, init scripts, properties, SELinux policy, and the rest of the recovery ramdisk are preserved as reference material.

The recovery has also been **tested on real hardware**. It was flashed to a Samsung SM-J330F running Android 9 (Pie), where it successfully wiped and mounted partitions and installed a custom ROM. This isn't just a tree that happens to look correct on paper.

**Update: this tree now compiles.** [TWRP 3.7.0](../../releases/tag/TWRP) is built from the corrected `BoardConfig.mk`/`device.mk` in this repo and has been flashed and confirmed working on a real J330F — full wipe, mount, and ROM install, same as the original 3.3.1-1 teardown, but built from source this time instead of extracted from someone else's image. Grab `recovery.tar` from the release page. If you're building OrangeFox for this device, start from 3.7.0's tree rather than 3.3.1-1 — it's the one with the fixes described below already applied.

## Where this came from

The source image was:

`twrp_3.3.1-1_sm-j330x_13819.tar`

It was originally posted on XDA:

https://xdaforums.com/t/recovery-root-twrp-3-3-1-1-samsung-galaxy-j3-2017-sm-j330f-j330fn-j330g-ds.3709056/

The release was credited to **ashyx** as the poster/tester. The actual builder isn't named in the thread — the closest thing to a name anywhere in this repo is `ro.build.user=mark` sitting in a build property, which is to say: some guy named Mark built this in 2019 and the internet has no further information on him.

The original Odin tar contains:

- `recovery.img` — 21,674,000 bytes
- `cache.img` — unrelated to the recovery

## Why does the recovery say Android 6.0.1?

Yes, really — a device that shipped on Android 7 and got this recovery built for Android 9 has a config file confidently claiming Android 6.0.1. It's not a typo, it's not a hoax, and no, you didn't get sent back in time. `recovery/root/default.prop` just still reports `ro.build.version.release=6.0.1`, left over from the older Omni 6.0.1-era `omni_j3y17lte` tree this was built from in August 2019. Nobody updated the sticker after renovating the house.

It's stale, not broken — recovery is its own small Linux environment and doesn't inherit the phone's Android version. What actually determines whether it works is kernel hardware support and the fstab partition layout, both of which were patched for the Pie-era setup and confirmed by flashing to a real J330F.

## Extraction method

The original `recovery.img` was unpacked directly rather than reconstructed from another source.

1. The Odin tar was unpacked and `recovery.img` was isolated. It uses the standard Android boot image format with a 2048-byte page size.

2. The boot image header was parsed manually. The image uses the `ANDROID!` magic and the standard v0/v1 layout.

3. The kernel and ramdisk were extracted using the offsets and sizes from the header:

   * `kernel_size = 14,748,680` bytes
   * kernel offset: `2048`
   * `ramdisk_size = 6,549,854` bytes
   * ramdisk offset: `14,751,744`

4. The extracted kernel was checked and identified as a valid little-endian ARM64 Linux kernel `Image`.

5. The ramdisk gzip stream was decompressed to `14,833,152` bytes.

6. The decompressed ramdisk was unpacked from its cpio archive (newc format, magic `070701`) into `recovery/root/`. Earlier notes in this repo called this an SVR4 archive — that was checked and is wrong; the magic bytes are newc, not old ASCII/SVR4. Doesn't change anything functionally, just correcting the record.

Nothing in the extracted recovery is being presented as source code when it isn't source code. The kernel and TWRP binaries are prebuilt artifacts from the working image.

## What's in the repo

### `kernel`

The extracted ARM64 kernel image.

This is a prebuilt kernel taken directly from the working recovery and tested on real hardware. Kernel source is also available separately; see the kernel source section below.

### `recovery/root/`

The pieces of the unpacked ramdisk that `device.mk` actually copies into a build:

* `etc/recovery.fstab` — the partition map used by recovery.
* `etc/mke2fs.conf`
* `init.recovery.hlthchrg.rc`
* `init.recovery.service.rc`
* `init.recovery.usb.rc` — recovery/device init scripts.

This is a trimmed subset, not the full ramdisk. The rest of what came out of the extraction step below — `init.rc`, `default.prop`, `sepolicy`/`file_contexts`/`property_contexts`/`service_contexts`, `sbin/` (TWRP userspace, `busybox`, `twrp`, `minzip`), `twres/`, `res/`, `oem/`, `system/` — was reviewed during the teardown but isn't checked into this repo. If you need those files, unpack `reference/recovery_orig.img` yourself (see "Extraction method" below); the offsets there are known to work.

### `reference/recovery_orig.img`

The original, unmodified `recovery.img` that everything in `recovery/root/` was extracted from.

It's kept around for comparison, verification, and re-flashing.

### Build-system files

The repo also contains:

* `BoardConfig.mk`
* `device.mk`
* `omni_j3y17lte.mk`
* `AndroidProducts.mk`
* `Android.mk`
* `vendorsetup.sh`

These provide the AOSP/Omni build scaffolding needed for:

```text
lunch omni_j3y17lte-eng
```

to resolve and for a build to get past the initial configuration stage.

There is an important distinction here, though: these files are **not recovered copies of the original device tree**. They couldn't be, because build-system files aren't stored inside a compiled recovery image.

Some values were recovered directly from the image or Samsung's kernel source. Others had to be filled in using standard conventions and what could reasonably be inferred from the device. Those are marked in the files themselves.

So the repo is structurally complete, but it isn't claiming that every build variable has been proven against the original builder's source.

## Using this as a build base

If you're trying to build a recovery for the J3 2017, the two pieces I'd trust first are:

* `kernel`
* `recovery/root/etc/recovery.fstab`

Both come from a recovery that was actually flashed and used on hardware.

`sbin/` and `twres/` from the original ramdisk are stock TWRP 3.3.1-1 userspace and resources, not OrangeFox — but they aren't checked into this repo (see "What's in the repo" above). Pull them from `reference/recovery_orig.img` if you need them.

If you're building OrangeFox, the usual approach here would be to keep the device-specific pieces that make the hardware work — the kernel, fstab, and relevant init configuration — and replace the TWRP userspace/theme with OrangeFox's own recovery components.

## `BoardConfig.mk` and `device.mk`

The included `BoardConfig.mk` and `device.mk` aren't recovered originals — a compiled recovery image doesn't contain build-system files, so these were written from what could be pulled out of the image and cross-checked against real hardware and Samsung's own kernel source.

### Verified

These values came directly from the boot image or ramdisk of the working recovery, from Samsung's released kernel source, or from real hardware.

* kernel base and offset information
* page size
* platform/board strings (see "Cross-checked against two more independent
  images" below for the `--board` string specifically — it went through
  a fabricated value, then blank, before landing on a real sourced one)
* fstab partition layout (mount points, device paths)
* boot/recovery partition byte sizes (confirmed via `/proc/partitions`)
* system/cache/userdata partition byte sizes
* display geometry (confirmed via visual check on real hardware)
* encryption-related flags
* kernel version
* exact defconfig name
* required kernel build flags
* HAL/driver-specific build flags

These have a hardware-backed source rather than being picked because they "look right."

**Correction, checked directly against the actual binaries rather than
just default.prop:** an earlier version of this repo set `TARGET_ARCH`
to `arm`/`armeabi-v7a` (32-bit), reasoning from `ro.zygote=zygote32` in
default.prop. That's wrong. `default.prop` in this ramdisk is stale
branding left over from an older 32-bit-era source tree (see "Why does
the recovery say Android 6.0.1?" above — same root cause) and doesn't
describe what's actually in `sbin/`.

Extracting the ramdisk and running `file` on the actual binaries shows
`sbin/recovery`, `sbin/twrp`, `sbin/busybox`, `sbin/mke2fs`,
`sbin/sgdisk`, `sbin/make_ext4fs`, `sbin/simg2img`, and `sbin/toolbox`
are all `ELF 64-bit ... ARM aarch64 ... interpreter /sbin/linker64` —
genuinely 64-bit binaries, not a 64-bit kernel wrapping 32-bit
userspace. `sbin/linker` (32-bit) is also present, but that's a
secondary compat linker, not evidence the primary recovery binary is
32-bit.

`TARGET_ARCH` is set to `arm64`, matching the binaries that are
actually in this recovery — checking the real ELF binaries with `file`
is a direct inspection of the compiled artifact, not a guess from a
prop string.

This tree has been built and flashed to a real SM-J330F, where it wiped
and mounted partitions and installed a custom ROM. If you fork this for
your own build and hit a value that doesn't match your hardware, open a
PR — see "Board revision — confirmed" above for the one check
(`hw_rev`/`hw_rev_end`) worth re-running per device.

## Kernel source

There is no longer a missing kernel-source piece here.

Samsung's GPL release for this exact device is available as the companion repo:


**`exynos7570-j3y17lte-kernel-source`**

It comes from Samsung's Open Source Release Center for build `J330FXXU3CSK2`:

https://opensource.samsung.com

A mirror is available here:

https://archive.org/details/j330fxxu3csk2_j330foxx3csk2

This is Samsung's actual kernel source for the device, not a third-party reconstruction. It is a Pie-targeted Linux `3.18.91` tree and contains:

```text
exynos7570-j3y17lte_defconfig
```

as well as the matching device-tree sources:

```text
exynos7570-j3y17lte_*.dts
```

Samsung's own `README_Kernel.txt` provides the build instructions, and the device tree identifies the board as:

```text
Samsung J3Y17LTE board based on Exynos7570
```

The `BoardConfig.mk` in this repo now uses values taken from that source where possible instead of relying on the earlier guesses.

## Resolved since initial publish

### Board revision — confirmed

Samsung's source contains four DTS variants for this device:

```text
_00   hw_rev 0,   hw_rev_end 0
_01   hw_rev 1,   hw_rev_end 1
_02   hw_rev 2,   hw_rev_end 3
_04   hw_rev 4,   hw_rev_end 255
```

There is no `_03` in the source drop.

The DTS files alone didn't say which variant maps to which physical unit — that had to come from real hardware. Booted into the working recovery on an actual SM-J330F and read the live device tree over `adb shell`:

```bash
adb shell
cat /proc/device-tree/model_info-hw_rev       # 4
cat /proc/device-tree/model_info-hw_rev_end   # 255
```

That's an exact match to `exynos7570-j3y17lte_eur_open_04.dts` and no other variant. `BoardConfig.mk` now points at that file specifically (`TARGET_KERNEL_DTB_NAME`).

Worth noting for anyone with a different J330F/FN/G unit: this confirms *this specific device's* revision, not that every J330F out there is `_04`. If you're forking this for your own unit, run the same `adb shell` check against your phone before assuming `_04` applies to you too.

## Corrected against a real published tree (aka the "well, that's embarrassing" section)

After this repo's `BoardConfig.mk`/`device.mk`/`Android.mk` were first
written from the teardown alone, a real published TWRP device tree for
this exact codename was found:

**`joephyu/android_device_samsung_j3y17lte`**
https://github.com/joephyu/android_device_samsung_j3y17lte

Unlike the Exynos7570 devices searched for earlier (this is not the same
SoC as the J5/J7 2017 Exynos7870 trees, which are a different chip
despite similar-looking codenames), this is a tree for the actual same
device, apparently built and working. It was diffed line by line against
this repo's files, and three real problems were found and fixed:

1. **`TARGET_ARCH`/`TARGET_CPU_ABI` were changed to arm/32-bit here, based
   on the joephyu tree — and that change was itself wrong.** This repo
   originally had arm64 set, reasoned only from the kernel binary being
   64-bit, which is a real gap in logic (kernel arch and userspace build
   target are different things). But the fix applied at the time — copying
   joephyu's 32-bit `arm`/`armeabi-v7a` setting — didn't actually check
   whether that tree's target matches this recovery. It doesn't: joephyu's
   tree is written for an Android 6.0-era Omni build, while this repo's own
   recovery is TWRP 3.3.1-1, tested against Android 9 (Pie) — see "Why does
   the recovery say Android 6.0.1?" above. Copying a 32-bit setting from a
   6.0-era tree onto a Pie-era recovery isn't a like-for-like correction,
   it's borrowing an answer from a different device generation.

   This has since been checked properly: the actual `sbin/` binaries in
   this ramdisk (`recovery`, `twrp`, `busybox`, `mke2fs`, `sgdisk`,
   `make_ext4fs`, `simg2img`, `toolbox`) were extracted and run through
   `file`, and all of them report `ELF 64-bit ... ARM aarch64 ...
   interpreter /sbin/linker64`. That's genuinely 64-bit userspace, not a
   64-bit kernel with 32-bit binaries on top. `TARGET_ARCH` is back to
   `arm64` / `arm64-v8a`, this time backed by inspecting the actual
   compiled binaries rather than either a stale prop string or an
   unchecked borrow from a different tree's Android version.

2. **`device.mk`'s product base was corrected, then reverted again.**
   joephyu's tree uses `full.mk` plus language/GPS config, so this repo
   was switched to match. That build failed with `system/bin/linker
   missing` — `full.mk` pulls in the whole system-partition package set,
   which changes how core bionic/linker targets get scheduled in a way
   that breaks the recovery link step for a recovery-only tree. Back on
   `embedded.mk`, the build completes and the resulting image is the one
   that's been flashed and tested. Don't switch to `full.mk` without
   reproducing and fixing that failure first.

3. **`TARGET_KERNEL_SOURCE` pointed at a path that was never synced.**
   Left active, this would have made the build look for kernel source
   that doesn't exist in this tree. Commented out; `TARGET_PREBUILT_KERNEL`
   (the confirmed-working extracted kernel) is now the active default.

A required file, `bootimg.mk`, was also missing entirely — `BoardConfig.mk`
referenced it but it was never added. It's generic TWRP build machinery,
not device-specific, and has been added.

One more product-identity mismatch, unrelated to the joephyu diff: this
tree's `device.mk`/`omni_j3y17lte.mk` had `PRODUCT_MODEL` hardcoded to
`SM-J330FN`, copied straight from this ramdisk's own `default.prop`. If
you're building for a J330F specifically, that's the wrong model string
for your unit — it's been corrected to `SM-J330F`, with a note in both
files that the source recovery this tree is built from is genuinely an
FN build, so treat anything model-specific here as FN-sourced, not
independently confirmed against an F.

Everything this repo had independently confirmed from real hardware —
boot/recovery partition sizes, display geometry, DTS board revision,
kernel boot offsets, fstab structure — was cross-checked against the
joephyu tree during this pass and matches. Those values are unchanged
and now have two independent sources agreeing, not just one.

## Cross-checked against two more independent images

Two more images, unrelated to both this repo's original teardown and the
joephyu tree above, were used to pressure-test the remaining values in `BoardConfig.mk`:

* an online-builder-generated recovery (TeamHovatek's builder, dated
  2026-08-12, `ro.omni.version=16.1.0-...-hovatek-HOMEMADE`) — confirmed
  by the person maintaining this repo to boot and flash successfully on
  a real SM-J330F
* Samsung's own **stock** recovery image for this device (not a TWRP
  build at all) — `ro.product.model=SM-J330F`,
  `ro.build.fingerprint=samsung/j3y17lteser/j3y17lte:9/PPR1.180610.011/
  J330FXWS4CUD4:user/release-keys`, `BOARD_OS_VERSION 9.0.0`,
  `BOARD_OS_PATCH_LEVEL 2021-04` — as close to ground truth as this repo
  has access to

What came out of that:

1. **`--board` string, resolved for real this time.** The value in this
   tree started as `SRPQE04B000RU`, inherited from prior tree lineage
   with no traceable source — never actually read off any image in this
   repo. When that was noticed, the field was checked directly against
   this repo's own `recovery_orig.img` header (`od -c` on the AIK-split
   board field) and found to be genuinely blank in that specific image,
   so the fabricated value was removed rather than left as an unsourced
   guess. Then Samsung's stock recovery.img (above) was checked the same
   way and its header field is **not** blank: `SRPQC17A001RU`, clean
   ASCII, no truncation. Since that image is confirmed-genuine Samsung
   firmware for this exact model, `--board SRPQC17A001RU` is now back in
   `BoardConfig.mk`, this time with an actual source.

2. **GPU string corrected: `mali-T720` → `mali-T720-MP2`.** Recovery
   ramdisks don't reference a GPU model anywhere (TWRP renders through
   the framebuffer, not the GPU driver), so this was never checkable from
   any image directly, including these two. It's sourced externally
   instead: five independent spec pages (Notebookcheck DE/EN, CPU-Monkey,
   PhonesSpecs, GSMArena) all agree the Exynos 7570 uses Mali-T720 MP2,
   and one names the SM-J330/Galaxy J3 2017 family specifically. The
   previous value was missing the MP2 core count, which some Mali kernel
   driver configs key off directly.

3. **`TARGET_2ND_ARCH` block removed.** The only 32-bit ELF anywhere in
   this repo's extracted ramdisk is `sbin/linker` — no 32-bit `.so`
   libraries or executables exist that would actually use it, and every
   TWRP tool binary is aarch64. Nothing in the recovery environment
   exercises a 32-bit code path, so the block was dead configuration
   weight, not a real requirement. If a real build breaks without it,
   that's new evidence to reopen this.

4. **One naming question raised, then resolved as a non-issue.** Both the
   hovatek build and Samsung's stock recovery use `fstab.samsungexynos7570`
   / `ro.hardware.chipname=exynos7570`, not this tree's
   `TARGET_BOOTLOADER_BOARD_NAME := universal7570` — looked like a
   discrepancy at first. It isn't one: Samsung's own stock `init.rc`
   carries `#universal7570` as an internal comment/board-codename marker,
   confirming `universal7570` is Samsung's own name for this board too.
   `exynos7570`/`samsungexynos7570` is a separate SoC-family naming
   convention used for HAL/service matching (`ro.hardware.chipname`,
   `fstab.<name>`), not a competing value for the same field. Both
   conventions coexist in Samsung's own stock image; this tree's value
   didn't need to change.

5. **Partition mapping cross-validated a second time.** Every core
   partition path in this tree's `recovery.fstab` (`BOOT`, `CACHE`,
   `SYSTEM`, `RECOVERY`, `EFS`, `RADIO`, `CPEFS`) matches the hovatek
   image's fstab exactly, same `by-name` block-device paths. Third
   independent source, same layout.

The hovatek image's `/data` fstab line is missing the
`encryptable=footer`/`length=-16384` flags this tree's `/data` line
carries. This tree keeps those flags: they match the footer-based FDE
this device actually uses, and the built, flashed TWRP 3.7.0 works
correctly with encrypted `/data` as a result.

## Known limitations

### Mali T720MP2 userspace

The GPL kernel source covers the kernel-side GPU driver only — it doesn't include the proprietary Mali userspace blob, which is normal for a GPL kernel release. Recovery doesn't need it (TWRP renders through the framebuffer), so this doesn't affect the build.

### Exact partition sizes

`recovery.fstab` gives mount points and device paths, not byte sizes. For exact sizes, pull them from a PIT file or read them directly off a device with `parted` or `fdisk`.

### Recovery-specific HAL components

Everything the working recovery uses is already present in the ramdisk and reflected in this tree — no separate HAL components were needed beyond what's here.

## Credits

* **ashyx** — posted and tested the original recovery release on XDA.
* **Some guy named Mark** — `ro.build.user=mark` is the only trace of him anywhere in this repo. No last name, no contact info, no further clues. If you're out there, Mark, thanks for building this recovery in 2019 and leaving zero other footprints.
* **[DirazCoder](https://github.com/DirazCoder)** — performed the extraction, teardown, and documentation independently, then took the corrected tree through a real build and flashed the result (TWRP 3.7.0) on hardware.

The original device tree was never published, so this repo exists to preserve the parts that could still be recovered from a working build and make them useful to the next person who has to work on this device.