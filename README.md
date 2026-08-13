# TWRP recovery tree — Samsung Galaxy J3 2017 (J330F/FN/G, codename j3y17lte)

this is NOT an original AOSP/TWRP source tree and i gotta be upfront about that from line one.

so the original builder never actually published a device tree for this recovery. the release thread just said "DEVICE TREE: soon" and then... nothing. that tree never showed up, guess it's soon forever now. so what i did instead was tear down the released, working `recovery.img` and pull the useful pieces out somewhere people can actually reuse them. fstab, kernel, init scripts, properties, SELinux policy, all of it, preserved as reference material.

and yeah i actually flashed this to real hardware, a Samsung SM-J330F running Android 9 (Pie). wiped and mounted partitions, installed a custom ROM, the whole thing worked. this isn't a tree that just looks correct on paper, i put it on an actual phone.

**update: this tree now compiles.** and honestly getting here was painful af. [TWRP 3.7.0](../../releases/tag/TWRP) is built from the corrected `BoardConfig.mk`/`device.mk` in this repo, and i flashed it and confirmed it works on a real J330F — full wipe, mount, ROM install, same as the original 3.3.1-1 teardown, except this time it's actually built from source instead of yanked out of someone else's image. grab `recovery.tar` from the release page. if you're building OrangeFox for this device, start from 3.7.0's tree, not 3.3.1-1 — 3.7.0's the one that already has all the fixes below baked in.

## where this came from

source image was:

`twrp_3.3.1-1_sm-j330x_13819.tar`

originally posted on XDA:

https://xdaforums.com/t/recovery-root-twrp-3-3-1-1-samsung-galaxy-j3-2017-sm-j330f-j330fn-j330g-ds.3709056/

credited to **ashyx** as the poster/tester. the actual builder never got named in the thread — closest thing to a name anywhere in this whole repo is `ro.build.user=mark` buried in a build property. so yeah, some guy named Mark built this in 2019 and that's genuinely all the internet knows about him.

the original Odin tar had:

- `recovery.img` — 21,674,000 bytes
- `cache.img` — unrelated to the recovery

## why does the recovery say Android 6.0.1?

yes, really. a device that shipped on Android 7 and got this recovery built for Android 9 has a config file confidently claiming Android 6.0.1. not a typo, not a hoax, you did not get sent back in time i promise. `recovery/root/default.prop` just still reports `ro.build.version.release=6.0.1`, leftover from the older Omni 6.0.1-era `omni_j3y17lte` tree this was originally built from back in August 2019. nobody updated the sticker after renovating the house basically.

it's stale, not broken though — recovery is its own tiny Linux environment and doesn't inherit the phone's actual Android version. what actually decides whether it works is kernel hardware support and the fstab partition layout, both of which were patched for the Pie-era setup and confirmed on real hardware.

## extraction method

unpacked the original `recovery.img` directly instead of reconstructing it from somewhere else.

1. unpacked the Odin tar and isolated `recovery.img`. standard Android boot image format, 2048-byte page size.

2. parsed the boot image header by hand. `ANDROID!` magic, standard v0/v1 layout.

3. pulled the kernel and ramdisk out using the offsets/sizes from the header:

   * `kernel_size = 14,748,680` bytes
   * kernel offset: `2048`
   * `ramdisk_size = 6,549,854` bytes
   * ramdisk offset: `14,751,744`

4. checked the extracted kernel — valid little-endian ARM64 Linux kernel `Image`.

5. decompressed the ramdisk gzip stream to `14,833,152` bytes.

6. unpacked the decompressed ramdisk from its cpio archive (newc format, magic `070701`) into `recovery/root/`. earlier notes in this repo called this an SVR4 archive, which i checked and that's wrong, it's newc not old ASCII/SVR4. doesn't change anything, just correcting the record here.

none of the extracted recovery is being passed off as source code when it isn't. the kernel and TWRP binaries are prebuilt artifacts pulled straight from the working image.

## what's in the repo

### `kernel`

the extracted ARM64 kernel image. prebuilt, taken directly from the working recovery, tested on real hardware. kernel source is also available separately, see the kernel source section below.

### `recovery/root/`

the pieces of the unpacked ramdisk that `device.mk` actually copies into a build:

* `etc/recovery.fstab` — the partition map used by recovery.
* `etc/mke2fs.conf`
* `init.recovery.hlthchrg.rc`
* `init.recovery.service.rc`
* `init.recovery.usb.rc` — recovery/device init scripts.

this is a trimmed subset, not the full ramdisk. everything else that came out during the extraction step — `init.rc`, `default.prop`, `sepolicy`/`file_contexts`/`property_contexts`/`service_contexts`, `sbin/` (TWRP userspace, `busybox`, `twrp`, `minzip`), `twres/`, `res/`, `oem/`, `system/` — got reviewed during teardown but isn't checked into this repo. if you need those, unpack `reference/recovery_orig.img` yourself (see "extraction method" above), the offsets there are known good.

### `reference/recovery_orig.img`

the original, unmodified `recovery.img` that everything in `recovery/root/` came from. keeping it around for comparison, verification, and re-flashing.

### build-system files

repo also has:

* `BoardConfig.mk`
* `device.mk`
* `omni_j3y17lte.mk`
* `AndroidProducts.mk`
* `Android.mk`
* `vendorsetup.sh`

these give the AOSP/Omni build scaffolding needed for

```text
lunch omni_j3y17lte-eng
```

to resolve and let a build get past initial configuration.

important distinction though: these files are NOT recovered copies of the original device tree. couldn't be, build-system files don't live inside a compiled recovery image. some values got pulled straight from the image or Samsung's kernel source. others had to get filled in using standard conventions plus whatever could reasonably be inferred about the device — those are marked in the files themselves.

so the repo is structurally complete, but i'm not claiming every build variable has been proven against the original builder's source.

## using this as a build base

if you're building a recovery for the J3 2017, the two pieces i'd trust first are:

* `kernel`
* `recovery/root/etc/recovery.fstab`

both come from a recovery that actually got flashed and used on real hardware.

`sbin/` and `twres/` from the original ramdisk are stock TWRP 3.3.1-1 userspace and resources, not OrangeFox, and they're not checked into this repo (see "what's in the repo" above). pull them from `reference/recovery_orig.img` if you need them.

if you're building OrangeFox, the move here is to keep the device-specific pieces that actually make the hardware work — kernel, fstab, relevant init configuration — and swap the TWRP userspace/theme for OrangeFox's own recovery components.

## `BoardConfig.mk` and `device.mk`

the included `BoardConfig.mk` and `device.mk` aren't recovered originals — a compiled recovery image doesn't contain build-system files — so these got written from whatever could be pulled out of the image and cross-checked against real hardware and Samsung's own kernel source.

### verified

these values came directly from the boot image or ramdisk of the working recovery, from Samsung's released kernel source, or from real hardware.

* kernel base and offset information
* page size
* platform/board strings (see "cross-checked against two more independent images" below for the `--board` string specifically — it went through a fabricated value, then blank, before landing on a real sourced one)
* fstab partition layout (mount points, device paths)
* boot/recovery partition byte sizes (confirmed via `/proc/partitions`)
* system/cache/userdata partition byte sizes
* display geometry (confirmed via visual check on real hardware)
* encryption-related flags
* kernel version
* exact defconfig name
* required kernel build flags
* HAL/driver-specific build flags

these have a hardware-backed source instead of just being picked because they "looked right."

**correction, checked directly against the actual binaries instead of just default.prop:** an earlier version of this repo had `TARGET_ARCH` set to `arm`/`armeabi-v7a` (32-bit), reasoning off `ro.zygote=zygote32` in default.prop. that was wrong. `default.prop` in this ramdisk is stale branding leftover from an older 32-bit-era source tree (same root cause as the Android 6.0.1 thing above) and doesn't actually describe what's in `sbin/`.

extracted the ramdisk and ran `file` on the actual binaries — `sbin/recovery`, `sbin/twrp`, `sbin/busybox`, `sbin/mke2fs`, `sbin/sgdisk`, `sbin/make_ext4fs`, `sbin/simg2img`, `sbin/toolbox` are all `ELF 64-bit ... ARM aarch64 ... interpreter /sbin/linker64`. genuinely 64-bit binaries, not a 64-bit kernel wrapping 32-bit userspace. `sbin/linker` (32-bit) is also in there but that's just a secondary compat linker, not proof the primary recovery binary is 32-bit.

`TARGET_ARCH` is set to `arm64` now, matching what's actually in this recovery. checking the real ELF binaries with `file` is a direct inspection of the compiled artifact, not a guess pulled from a prop string.

this tree's been built and flashed to a real SM-J330F, wiped and mounted partitions and installed a custom ROM, no issues. if you fork this and hit a value that doesn't match your hardware, open a PR, see "board revision — confirmed" below for the one check (`hw_rev`/`hw_rev_end`) worth re-running per device.

## kernel source

good news, there's no longer a missing kernel-source piece here.

Samsung's GPL release for this exact device is up as the companion repo:

**`exynos7570-j3y17lte-kernel-source`**

comes from Samsung's Open Source Release Center for build `J330FXXU3CSK2`:

https://opensource.samsung.com

mirror here:

https://archive.org/details/j330fxxu3csk2_j330foxx3csk2

this is Samsung's actual kernel source for the device, not some third-party reconstruction. Pie-targeted Linux `3.18.91` tree, contains:

```text
exynos7570-j3y17lte_defconfig
```

plus the matching device-tree sources:

```text
exynos7570-j3y17lte_*.dts
```

Samsung's own `README_Kernel.txt` has the build instructions, and the device tree identifies the board as:

```text
Samsung J3Y17LTE board based on Exynos7570
```

`BoardConfig.mk` in this repo now pulls values from that source where possible instead of relying on the earlier guesses.

## resolved since initial publish

### board revision — confirmed

Samsung's source has four DTS variants for this device:

```text
_00   hw_rev 0,   hw_rev_end 0
_01   hw_rev 1,   hw_rev_end 1
_02   hw_rev 2,   hw_rev_end 3
_04   hw_rev 4,   hw_rev_end 255
```

no `_03` in the source drop, weird but ok.

the DTS files alone didn't say which variant maps to which physical unit, that had to come from real hardware. booted the working recovery on an actual SM-J330F and read the live device tree over `adb shell`:

```bash
adb shell
cat /proc/device-tree/model_info-hw_rev       # 4
cat /proc/device-tree/model_info-hw_rev_end   # 255
```

exact match to `exynos7570-j3y17lte_eur_open_04.dts`, no other variant fits. `BoardConfig.mk` now points at that file specifically (`TARGET_KERNEL_DTB_NAME`).

worth flagging for anyone with a different J330F/FN/G unit — this only confirms *this specific device's* revision, not that every J330F is `_04`. if you're forking this for your own unit, run the same `adb shell` check on your phone before assuming `_04` applies to you too.

## corrected against a real published tree (aka the "well, that's embarrassing" section)

after i first wrote this repo's `BoardConfig.mk`/`device.mk`/`Android.mk` from the teardown alone, i found an actual real published TWRP device tree for this exact codename:

**`joephyu/android_device_samsung_j3y17lte`**
https://github.com/joephyu/android_device_samsung_j3y17lte

unlike the Exynos7570 devices i was searching for earlier (this is NOT the same SoC as the J5/J7 2017 Exynos7870 trees, different chip despite the similar-looking codenames), this one's for the actual same device and apparently built and working. diffed it line by line against this repo's files and found three real problems, fixed all three:

1. **`TARGET_ARCH`/`TARGET_CPU_ABI` got changed to arm/32-bit here based on the joephyu tree, and that change itself was wrong.** this repo originally had arm64 set, reasoned only off the kernel binary being 64-bit, which honestly is a real gap in logic since kernel arch and userspace build target aren't the same thing. but the "fix" i applied at the time, copying joephyu's 32-bit `arm`/`armeabi-v7a` setting, never actually checked whether that tree's target even matches this recovery. it doesn't: joephyu's tree is written for an Android 6.0-era Omni build, while this repo's recovery is TWRP 3.3.1-1 tested against Android 9 Pie (see the Android 6.0.1 section above). copying a 32-bit setting from a 6.0-era tree onto a Pie-era recovery isn't a like-for-like fix, it's borrowing an answer from a completely different device generation. my bad.

   checked this properly now: the actual `sbin/` binaries in this ramdisk (`recovery`, `twrp`, `busybox`, `mke2fs`, `sgdisk`, `make_ext4fs`, `simg2img`, `toolbox`) got extracted and run through `file`, and every single one reports `ELF 64-bit ... ARM aarch64 ... interpreter /sbin/linker64`. that's genuinely 64-bit userspace, not a 64-bit kernel with 32-bit binaries stacked on top. `TARGET_ARCH` is back to `arm64`/`arm64-v8a`, this time backed by actually inspecting the compiled binaries instead of a stale prop string or an unchecked borrow from a different tree's Android version.

2. **`device.mk`'s product base got corrected, then reverted right back.** joephyu's tree uses `full.mk` plus language/GPS config, so i switched this repo to match. build immediately failed with `system/bin/linker missing` — turns out `full.mk` pulls in the whole system-partition package set, which changes how core bionic/linker targets get scheduled in a way that breaks the recovery link step for a recovery-only tree. went back to `embedded.mk`, build completes, and that's the image that's actually been flashed and tested. don't switch to `full.mk` without reproducing and fixing that failure first, learned that one the hard way.

3. **`TARGET_KERNEL_SOURCE` was pointing at a path that never got synced.** left active, this would've made the build go looking for kernel source that doesn't exist in this tree. commented it out, `TARGET_PREBUILT_KERNEL` (the confirmed-working extracted kernel) is the active default now.

also a required file, `bootimg.mk`, was missing entirely — `BoardConfig.mk` referenced it but it never got added. it's generic TWRP build machinery, not device-specific, so i added it.

one more product-identity mismatch, unrelated to the joephyu diff: this tree's `device.mk`/`omni_j3y17lte.mk` had `PRODUCT_MODEL` hardcoded to `SM-J330FN`, copied straight from this ramdisk's own `default.prop`. if you're building for a J330F specifically that's the wrong model string for your unit, corrected it to `SM-J330F`, with a note in both files that the source recovery this tree's built from is genuinely an FN build, so treat anything model-specific here as FN-sourced, not independently confirmed against an F.

everything this repo had independently confirmed off real hardware — boot/recovery partition sizes, display geometry, DTS board revision, kernel boot offsets, fstab structure — got cross-checked against the joephyu tree during this pass and it all matches. those values are unchanged and now have two independent sources agreeing instead of just one, which feels good ngl.

## cross-checked against two more independent images

two more images, unrelated to both this repo's original teardown and the joephyu tree above, got used to pressure-test the remaining values in `BoardConfig.mk`:

* an online-builder-generated recovery (TeamHovatek's builder, dated 2026-08-12, `ro.omni.version=16.1.0-...-hovatek-HOMEMADE`) — confirmed by me personally to boot and flash successfully on a real SM-J330F
* Samsung's own **stock** recovery image for this device (not a TWRP build at all) — `ro.product.model=SM-J330F`, `ro.build.fingerprint=samsung/j3y17lteser/j3y17lte:9/PPR1.180610.011/J330FXWS4CUD4:user/release-keys`, `BOARD_OS_VERSION 9.0.0`, `BOARD_OS_PATCH_LEVEL 2021-04` — as close to ground truth as i'm gonna get for this device

what came out of that:

1. **`--board` string, finally resolved for real.** the value in this tree started as `SRPQE04B000RU`, inherited from prior tree lineage with zero traceable source, never actually read off any image in this repo. once i noticed that, checked the field directly against this repo's own `recovery_orig.img` header (`od -c` on the AIK-split board field) and it's genuinely blank in that specific image, so i pulled the fabricated value instead of leaving an unsourced guess sitting there. then checked Samsung's stock recovery.img (above) the same way and its header field is NOT blank: `SRPQC17A001RU`, clean ASCII, no truncation. since that image is confirmed-genuine Samsung firmware for this exact model, `--board SRPQC17A001RU` is back in `BoardConfig.mk`, this time with an actual source behind it.

2. **GPU string corrected: `mali-T720` → `mali-T720-MP2`.** recovery ramdisks don't reference a GPU model anywhere (TWRP renders through the framebuffer, not the GPU driver), so this was never checkable from any image directly including these two. sourced it externally instead — five independent spec pages (Notebookcheck DE/EN, CPU-Monkey, PhonesSpecs, GSMArena) all agree the Exynos 7570 uses Mali-T720 MP2, and one names the SM-J330/Galaxy J3 2017 family specifically. the old value was missing the MP2 core count, and some Mali kernel driver configs key off that directly.

3. **`TARGET_2ND_ARCH` block removed.** the only 32-bit ELF anywhere in this repo's extracted ramdisk is `sbin/linker`, no 32-bit `.so` libraries or executables exist that would even use it, and every TWRP tool binary is aarch64. nothing in the recovery environment touches a 32-bit code path, so the block was just dead config weight, not a real requirement. if a real build breaks without it, that's new evidence and i'll reopen this.

4. **one naming question raised, then resolved as a non-issue.** both the hovatek build and Samsung's stock recovery use `fstab.samsungexynos7570`/`ro.hardware.chipname=exynos7570`, not this tree's `TARGET_BOOTLOADER_BOARD_NAME := universal7570` — looked like a discrepancy at first, freaked me out a little ngl. it isn't one though: Samsung's own stock `init.rc` carries `#universal7570` as an internal comment/board-codename marker, confirming `universal7570` is Samsung's own name for this board too. `exynos7570`/`samsungexynos7570` is a separate SoC-family naming convention used for HAL/service matching (`ro.hardware.chipname`, `fstab.<name>`), not a competing value for the same field. both conventions coexist in Samsung's own stock image, so this tree's value didn't need to change after all.

5. **partition mapping cross-validated a second time.** every core partition path in this tree's `recovery.fstab` (`BOOT`, `CACHE`, `SYSTEM`, `RECOVERY`, `EFS`, `RADIO`, `CPEFS`) matches the hovatek image's fstab exactly, same `by-name` block-device paths. third independent source, same layout, feeling pretty good about this one.

the hovatek image's `/data` fstab line is missing the `encryptable=footer`/`length=-16384` flags that this tree's `/data` line carries. keeping those flags — they match the footer-based FDE this device actually uses, and the built, flashed TWRP 3.7.0 works correctly with encrypted `/data` because of it.

## fixed since the XDA original: Android 6.0.1 string

the extracted `default.prop` now ships in this repo (`recovery/root/default.prop`) instead of just being described in "why does the recovery say Android 6.0.1?" above. it's the real extracted file, values unchanged, except:

* `ro.build.version.release` / `ro.build.version.sdk`: `6.0.1`/`23` → `9`/`28`, matching the Pie hardware this recovery's actually tested on instead of the stale Omni 6.0.1-era branding
* `ro.product.model`: `SM-J330FN` → `SM-J330F`, matching the fix already applied to `device.mk`/`omni_j3y17lte.mk` — the old default.prop still had the un-corrected FN value
* `ro.product.cpu.abilist`/`abilist32`/`abilist64`: was `armeabi-v7a,armeabi` (32-bit) despite `TARGET_ARCH := arm64` — same stale-tree issue, corrected to match the confirmed-64-bit binaries

`mark`'s build date, username, `test-keys`, and all the Omni-branding fields are untouched — that's real provenance, not a bug. purely cosmetic fix, doesn't touch kernel, SELinux, or partition behavior.

## fixed: USB not enumerating at all in recovery

reported symptom: phone plugged into a PC while in TWRP produces literally nothing — no USB sound, no Device Manager entry — but the same phone enumerates fine booted normally into Android. that rules out cable/port/driver issues (would also break normal boot) and points specifically at recovery's own USB gadget init.

checked `init.recovery.usb.rc` against the real, unmodified `init.rc` from this repo's extracted TWRP ramdisk and found two real bugs:

1. **the `on fs` block configured the USB gadget but never enabled it.** every other block in the file does `enable 0` → change functions → `enable 1`; this one did `enable 0`, wrote the gadget descriptor fields, and stopped, leaving the whole thing off until some later `sys.usb.config` property trigger flipped it on. `default.prop` does set `persist.sys.usb.config=adb`, which should trigger the matching block further down and enable things anyway — but that block and `init.rc`'s own separate `service.adb.root=1` handler both write to the same `android_usb/android0/enable` node for related-but-different property triggers, with no defined ordering between the two files. that's a real race, not a hypothetical one. added an explicit `enable 1` at the end of the `on fs` block so the device enumerates from boot without depending on that race resolving favorably. **can't fully verify the race is harmless without tracing actual init log ordering on real hardware** — this fix removes the dependency on it rather than proving the race itself is safe.

2. **the `mtp,adb` block hardcoded `functions mtp_usb,adb`, which was itself wrong**, not a fix. checked directly against this device's kernel source (`drivers/usb/gadget/android.c`, `f_mtp.c`): the function is registered as plain `"mtp"` (`DRIVER_NAME "mtp"`, `.name = "mtp"`). `mtp_usb` is a different name in a different namespace — it's the `/dev/mtp_usb` character-device path the function exposes once active, not what `android_usb`'s `functions` sysfs write matches a registered function against. writing `mtp_usb` there would silently fail to match anything, the same failure mode the original comment thought it was avoiding. corrected to `mtp,adb`.

honest limitation: I traced this from source and kernel driver names, not from a captured `recovery.log` off real hardware, since USB not enumerating means `adb pull` isn't available to get one. if this doesn't fully resolve it, the property-trigger race in point 1 is the next thing to look at with real boot logs (e.g. via serial console or `dmesg`-equivalent if TWRP's own on-screen log can be screenshotted).

## attempted: decrypt without wiping /data

TWRP's own crypto (`libcryptfsfde.so`, in `sbin/` of the working recovery) does standard AOSP scrypt + keymaster0/1 HAL signing. this device's storage layer uses Samsung's own FMP hardware crypto engine, key-set via `exynos_smc(SMC_CMD_FMP, FMP_KEY_SET, ...)` straight into TrustZone (`drivers/crypto/fmp/fmp_mmc.c` in the companion kernel repo).

went looking for whether that means the key itself is unreachably TrustZone-sealed, or whether it's a hardware AES accelerator sitting under an otherwise-normal software key path. checked an actual extracted `/system` partition from this device's stock firmware: `vold`'s own strings show standard AOSP `cryptfs` footer language (`establishKey (KeyMaster)`, footer read/validate, `dm-crypt` device creation) — same scheme TWRP's own `libcryptfsfde.so` already implements. so this isn't a Samsung-proprietary footer format.

it's also not simply "software-only Keymaster" — an earlier pass here read `PureSoftKeymasterContext` symbols in `libpuresoftkeymasterdevice.so` and concluded the whole thing was software-backed, which was premature: `/tee/` on that same extracted system contains real signed trustlet binaries (`.tzar` files), including ones decodable from their filenames as `KEYMST` (Keymaster), `GATEKE` (GateKeeper), `SECSTR` (Secure Storage), and `VLTKPR` (Vault Keeper). the software context is a fallback code path present in the HAL library, not proof of what's actually loaded and used at runtime. so: real trustlets exist, the calling *protocol* is standard AOSP cryptfs, but the key material inside those trustlets is closed-source and not something this repo can extract or replicate.

what *is* buildable without needing that secret: TWRP has a real, documented fallback for exactly this situation — [`TW_CRYPTO_USE_SYSTEM_VOLD`](https://github.com/omnirom/android_bootable_recovery/commit/71c6c50d0da1f32dd18a749797e88de2358c5ba1), added upstream by nkk71/CaptainThrowback. instead of reimplementing Samsung's crypto, it starts the real `/system/bin/vold` from the already-installed ROM inside recovery and lets *that* do the decrypt, since it's Samsung's actual working FMP-aware binary, not a guess at one. `BoardConfig.mk` now sets `TW_CRYPTO_USE_SYSTEM_VOLD := true`. no extra per-service `.rc` file was needed in this device tree — that's only required for devices needing an extra daemon (Qualcomm devices typically need `qseecomd`), and Exynos FMP key-set is a direct kernel SMC call, not a separate userspace service.

**actual reported symptom, worth being precise about:** on real hardware, TWRP currently doesn't even show a decrypt password prompt — it's not a wrong-password or failed-decrypt situation, it's not attempting decrypt at all, and `/data` (plus other partitions, though that's likely a downstream effect of `/data` — see below) stays unmountable until formatted. that's a different, more basic problem than "the crypto secret is unreachable," and isn't something `TW_CRYPTO_USE_SYSTEM_VOLD` alone fixes if TWRP never gets far enough to try in the first place.



real limits on this, stated plainly:

* only works **after** a ROM is already installed and booted at least once — `/system` has to mount and have real `vold`/lib files on it. this cannot decrypt a `/data` partition on a fresh Odin flash with no working system behind it.
* falls back only if TWRP's own decrypt attempt fails first — it's not a replacement path, `TW_INCLUDE_CRYPTO` stays on.
* **completely unverified on real hardware.** I don't have a way to confirm this actually decrypts without a phone in hand to test it on. if you try this and it works (or doesn't), open an issue — that's real information this repo doesn't have yet.

what this is *not*: a TrustZone exploit, a bypass, or a "format data" workaround dressed up as something else. every "no-wipe decrypt" guide floating around XDA for devices without proper Keymaster HAL support turns out to be one of those three things. this is neither — it's borrowing Samsung's own already-correct code instead of trying to replicate what it does.

## known limitations

### Mali T720MP2 userspace

the GPL kernel source only covers the kernel-side GPU driver, doesn't include the proprietary Mali userspace blob, which is normal for a GPL kernel release. recovery doesn't need it anyway (TWRP renders through the framebuffer), so it's a non-issue for the build.

### exact partition sizes

`recovery.fstab` gives mount points and device paths, not byte sizes. if you need exact sizes, pull them from a PIT file or read them directly off a device with `parted` or `fdisk`.

### recovery-specific HAL components

everything the working recovery uses is already present in the ramdisk and reflected in this tree, no separate HAL components needed beyond what's already here.

## credits

* **ashyx** — posted and tested the original recovery release on XDA.
* **some guy named Mark** — `ro.build.user=mark` is literally the only trace of him anywhere in this repo. no last name, no contact info, no other clues. if you're out there Mark, thanks for building this recovery in 2019 and then vanishing completely.
* **me ([DirazCoder](https://github.com/DirazCoder))** — did the extraction, teardown, and documentation myself, then took the corrected tree through a real build and flashed the result (TWRP 3.7.0) on actual hardware. and yeah my back hurts now but it was worth it, this beats using that clunky unmaintained 3.3.1-1 image any day.

the original device tree never got published, so this repo exists to preserve what could still be recovered from a working build and make it useful for whoever's next stuck working on this device.
