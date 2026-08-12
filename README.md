# TWRP recovery tree — Samsung Galaxy J3 2017 (J330F/FN/G, codename j3y17lte)

This is **not an original AOSP/TWRP source tree**.

The original builder never published the device tree for this recovery. The release thread only ever said "DEVICE TREE: soon", and that tree never showed up. What this repo does instead is tear down the released, working `recovery.img` and put the useful pieces somewhere they can actually be reused.

That means the fstab, kernel, init scripts, properties, SELinux policy, and the rest of the recovery ramdisk are preserved as reference material.

The recovery has also been **tested on real hardware**. It was flashed to a Samsung SM-J330F running Android 9 (Pie), where it successfully wiped and mounted partitions and installed a custom ROM. This isn't just a tree that happens to look correct on paper.

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

Yes, really — a device that shipped on Android 7 and got this recovery built for Android 9 has a config file confidently claiming Android 6.0.1. It's not a typo, it's not a hoax, and no, you didn't get sent back in time. `recovery_root/default.prop` just still reports `ro.build.version.release=6.0.1`, left over from the older Omni 6.0.1-era `omni_j3y17lte` tree this was built from in August 2019. Nobody updated the sticker after renovating the house.

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

6. The decompressed ramdisk was unpacked from its SVR4 cpio archive (no CRC) into `recovery_root/`.

Nothing in the extracted recovery is being presented as source code when it isn't source code. The kernel and TWRP binaries are prebuilt artifacts from the working image.

## What's in the repo

### `kernel`

The extracted ARM64 kernel image.

This is a prebuilt kernel taken directly from the working recovery and tested on real hardware. Kernel source is also available separately; see the kernel source section below.

### `recovery_root/`

The complete unpacked recovery ramdisk.

The important parts include:

* `etc/recovery.fstab` — the partition map used by recovery.
* `init.rc`
* `init.recovery.hlthchrg.rc`
* `init.recovery.service.rc`
* `init.recovery.usb.rc` — recovery/device init scripts.
* `default.prop`
* `file_contexts`
* `property_contexts`
* `seapp_contexts`
* `service_contexts`
* `sepolicy`
* `selinux_version` — SELinux and property configuration.
* `sbin/` — TWRP 3.3.1-1 userspace, including `busybox`, `twrp`, `minzip`, and the other recovery binaries.
* `twres/` — TWRP theme and UI assets.
* `ueventd.rc`
* `res/`
* `oem/`
* `system/`
* `license/` — the rest of the recovery scaffolding.

The ramdisk contents were extracted from the original working image, so these files aren't reconstructed guesses.

### `recovery_orig.img`

The original, unmodified `recovery.img` that everything in `recovery_root/` was extracted from.

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
* `recovery_root/etc/recovery.fstab`

Both come from a recovery that was actually flashed and used on hardware.

The contents of `sbin/` and `twres/` are stock TWRP 3.3.1-1 userspace and resources. They are not OrangeFox.

If you're building OrangeFox, the usual approach here would be to keep the device-specific pieces that make the hardware work — the kernel, fstab, and relevant init configuration — and replace the TWRP userspace/theme with OrangeFox's own recovery components.

## `BoardConfig.mk` and `device.mk`

Read this part before using either file as if it were an original source tree.

The included `BoardConfig.mk` and `device.mk` are **skeletons**, not recovered originals. A compiled recovery image doesn't contain these files, so they had to be written from the information that could actually be recovered.

Each value in the files is marked as either **VERIFIED** or **UNVERIFIED / TEMPLATE**.

### VERIFIED

These values came directly from the boot image or ramdisk of the working recovery, or from Samsung's released kernel source.

Examples include:

* kernel base and offset information
* page size
* platform/board strings
* fstab partition layout (mount points, device paths)
* boot/recovery partition byte sizes (confirmed via `/proc/partitions`)
* display geometry (confirmed via visual check on real hardware)
* encryption-related flags
* kernel version
* exact defconfig name
* required kernel build flags

These have a hardware-backed source rather than being picked because they "look right."

**Correction (see "Corrected against a real published tree" below):** an
earlier version of this list included "architecture" as VERIFIED. That
was wrong — `TARGET_ARCH`/`TARGET_CPU_ABI` describe the userspace build
target, not something a compiled binary teardown can determine, and the
value originally set here (arm64) was an incorrect guess. It's fixed now,
see below.

### UNVERIFIED / TEMPLATE

These are values where the compiled recovery didn't contain enough information to recover the original setting.

Examples include:

* system/cache/userdata partition byte sizes (boot/recovery sizes ARE now
  confirmed — see below; these three are still sourced from a reference
  tree only, not independently measured on this device)
* HAL/driver-specific build flags
* other source-tree-only configuration

The values are there so the build system has something sensible to work with, but they should be checked before being treated as authoritative.

If you build this tree and confirm one of the currently unverified values, please send a PR correcting it. That's the easiest way to turn this from the best surviving reference into a more complete device tree for whoever needs it next.

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

1. **`TARGET_ARCH`/`TARGET_CPU_ABI` were wrong.** This repo had them set
   to arm64 (with arm as a secondary ABI), reasoned from the kernel
   binary genuinely being 64-bit. That reasoning conflated the kernel's
   architecture with the userspace build target — two different things,
   and yes, this repo confidently marked "architecture" as VERIFIED
   before finding that out. Nothing like a good published tree to remind
   you that "the kernel is 64-bit" and "the build should be 64-bit" are
   not, in fact, the same sentence.
   The joephyu tree builds a 32-bit-only userspace (`arm`/`armeabi-v7a`)
   on top of the 64-bit kernel, a normal split for this SoC generation.
   Building with the old arm64 setting would very likely have failed at
   `lunch` or produced binaries incompatible with this device's
   32-bit-only vendor blobs.

2. **`device.mk` inherited the wrong product base.** It called
   `embedded.mk` (a minimal base meant for non-phone targets like TVs)
   instead of `full.mk` plus language/GPS config. Corrected to match the
   proven tree.

3. **`TARGET_KERNEL_SOURCE` pointed at a path that was never synced.**
   Left active, this would have made the build look for kernel source
   that doesn't exist in this tree. Commented out; `TARGET_PREBUILT_KERNEL`
   (the confirmed-working extracted kernel) is now the active default.

A required file, `bootimg.mk`, was also missing entirely — `BoardConfig.mk`
referenced it but it was never added. It's generic TWRP build machinery,
not device-specific, and has been added.

Everything this repo had independently confirmed from real hardware —
boot/recovery partition sizes, display geometry, DTS board revision,
kernel boot offsets, fstab structure — was cross-checked against the
joephyu tree during this pass and matches. Those values are unchanged
and now have two independent sources agreeing, not just one.

## What's still unknown

### Mali T720MP2 userspace

The GPL source covers the kernel-side GPU driver.

It does not include the proprietary Mali userspace blob. That's normal for a GPL kernel release. Recovery may not need the GPU userspace components anyway, but if a particular build does, that part still needs to be sourced separately.

### Exact partition sizes

The fstab tells recovery what the partitions are and how they should be mounted. It doesn't give you the exact byte size of every partition.

If exact sizes are required for a build, get them from a PIT file or directly from a device using something like `parted` or `fdisk`.

### Recovery-specific HAL components

There may be device-specific recovery C++ HAL components that aren't obvious from the extracted ramdisk. There isn't enough surviving source material to say for certain whether any existed beyond what is already present in the working image.

## Credits

* **ashyx** — posted and tested the original recovery release on XDA.
* **Some guy named Mark** — `ro.build.user=mark` is the only trace of him anywhere in this repo. No last name, no contact info, no further clues. If you're out there, Mark, thanks for building this recovery in 2019 and leaving zero other footprints.
* **[DirazCoder](https://github.com/DirazCoder)** — performed the extraction, teardown, and documentation independently.

The original device tree was never published, so this repo exists to preserve the parts that could still be recovered from a working build and make them useful to the next person who has to work on this device.