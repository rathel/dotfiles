# Plan: Migrate from systemd-boot to Limine

**Status:** Planning only — no bootloader changes are included in this file.

## Current system snapshot

Collected on 2026-07-16:

- Firmware: UEFI x86_64; Secure Boot is disabled.
- Current bootloader: systemd-boot 259-2-arch.
- ESP: `/dev/sdb1`, FAT32, mounted at `/boot` (about 600 MiB free).
- Root: `/dev/sdb2`, Btrfs; current systemd-boot entry uses
  `root=PARTUUID=7752dd29-05db-4240-8ee1-2b4ea95ad29a zswap.enabled=0 rw rootfstype=btrfs`.
- Installed kernels and initramfs files include `linux`, `linux-lts`, and `linux-zen`.
- Current default entry is `linux-lts.conf`; the loader menu currently has no explicit timeout.
- The `limine` package is already installed, but no Limine configuration or EFI entry has been created.

## Safety rules

- Perform the migration from a TTY or a reliable terminal, not during a fragile graphical session.
- Do not remove systemd-boot until Limine has booted successfully at least once.
- Keep an Arch install USB available. Know the Btrfs subvolume/layout and how to mount the root and ESP before starting.
- Record command output and stop if any path, UUID/PARTUUID, or kernel/initramfs name differs from this plan.

## Phase 1 — Verify and back up

1. Confirm the machine is booted in UEFI mode:
   ```sh
   test -d /sys/firmware/efi && echo UEFI
   ```
2. Re-check the actual mounts and identifiers:
   ```sh
   findmnt /boot
   lsblk -f
   blkid /dev/sdb1 /dev/sdb2
   bootctl status
   ```
3. Back up the complete ESP and current EFI variables/configuration to a root-owned directory outside `/boot` (for example `/root/bootloader-backup-<date>`). Include:
   - `/boot/EFI/`
   - `/boot/loader/`
   - output of `efibootmgr -v`
   - output of `bootctl status`
4. Inspect the installed Limine package before copying anything. Confirm the exact x86_64 EFI binary path and whether the package ships a helper such as `limine-entry-tool`:
   ```sh
   pacman -Ql limine
   limine --help
   command -v limine-entry-tool || true
   ```

## Phase 2 — Design the Limine configuration

1. Use `/boot/limine.conf` as the Limine configuration file, unless the installed package/documentation specifies another supported location.
2. Create entries for all installed kernels, preserving the existing root options. Each entry should provide:
   - a clear title;
   - `protocol: linux`; 
   - the matching `/vmlinuz-*` path;
   - the matching `/initramfs-*` path;
   - the existing `root=PARTUUID=...`, `zswap.enabled=0`, `rw`, and `rootfstype=btrfs` options;
   - `/intel-ucode.img` before the normal initramfs where appropriate.
3. Make `linux-lts` the initial default, matching the current working system. Add a modest menu timeout and retain a visible fallback entry. Validate the syntax against the installed Limine version’s documentation before installation.
4. Decide whether kernel updates will be handled by the installed package’s Limine entry-generation hook/tool. If no supported hook is present, plan a tested pacman hook or a manually maintained config; do not assume systemd-boot’s automatic BLS discovery will continue to update Limine.

## Phase 3 — Install Limine alongside systemd-boot

1. Ensure the package is current (install/update only after reviewing the proposed transaction):
   ```sh
   sudo pacman -S limine
   ```
2. Create a dedicated EFI directory, such as `/boot/EFI/limine/`, and copy the verified 64-bit Limine EFI executable there using the package’s documented path. Do not overwrite `EFI/BOOT/BOOTX64.EFI` yet.
3. Write `/boot/limine.conf` with the tested entries from Phase 2.
4. Create a new UEFI NVRAM entry pointing at the Limine EFI executable, using the verified disk and partition:
   ```sh
   sudo efibootmgr --create --disk /dev/sdb --part 1 \
     --label "Limine" --loader '\\EFI\\limine\\limine_x64.efi'
   ```
   Check the actual filename/case and resulting `efibootmgr -v` output first; adjust the command if the package uses a different binary name.
5. Put the new Limine entry first in the boot order, but retain the existing `Linux Boot Manager` entry as a rollback path:
   ```sh
   sudo efibootmgr -v
   sudo efibootmgr --bootorder <LIMINE_ID>,<SYSTEMD_BOOT_ID>,...
   ```

## Phase 4 — Test before removing systemd-boot

1. Reboot and select `Limine` from the firmware boot menu if the firmware does not automatically use the new first entry.
2. At the Limine menu, boot `Arch Linux (linux-lts)` first. Verify the running kernel, root mount, graphics/session, networking, and storage:
   ```sh
   uname -r
   findmnt /
   systemctl --failed
   ```
3. Reboot and test at least one additional entry (normal `linux` and/or `linux-zen`). Confirm that the fallback entry remains usable.
4. Test a kernel/initramfs update in a controlled window. Confirm the new files exist in `/boot` and that Limine’s menu/config is updated. If it is not automatic, implement and test the approved package hook before proceeding.
5. Reboot twice using Limine, and verify `bootctl status`/`efibootmgr -v` show Limine as the active loader. Keep the systemd-boot files and NVRAM entry during this observation period.

## Phase 5 — Retire systemd-boot (optional, only after successful testing)

1. Save a final backup and final `efibootmgr -v` output.
2. Remove only the old systemd-boot NVRAM entry after confirming Limine works and the firmware can find it. Keep the fallback EFI path until a later maintenance window.
3. Remove old `EFI/systemd/` and the systemd-boot-managed loader files only if there is a clear reason; leave kernel/initramfs files and the Limine config intact. Avoid deleting `/boot/EFI/BOOT/BOOTX64.EFI` unless its replacement has been verified.
4. If `systemd-boot` was installed solely for the bootloader, determine package ownership/dependencies and remove it only after checking that this will not remove required systemd components:
   ```sh
   pacman -Qo /boot/EFI/systemd/systemd-bootx64.efi
   pacman -Qi systemd
   ```

## Rollback

If Limine fails to boot, use the firmware boot menu to select **Linux Boot Manager** (systemd-boot). If that fails, boot the Arch USB in UEFI mode, mount the installed ESP at `/mnt/boot`, restore `/boot/EFI` and `/boot/loader` from the backup, and recreate the systemd-boot NVRAM entry with `bootctl install --esp-path=/mnt/boot` (after chrooting into the installed system as appropriate). Do not erase the backup until several successful Limine boots and a kernel update have been verified.

## Completion checklist

- [ ] ESP, root identifiers, Btrfs layout, and kernel command line rechecked.
- [ ] ESP/config/NVRAM backups stored safely.
- [ ] Limine EFI binary and config paths verified against the installed package.
- [ ] Limine boots `linux-lts`, `linux`, and/or `linux-zen`.
- [ ] Kernel update behavior is tested and documented.
- [ ] Firmware boot order and rollback path confirmed.
- [ ] systemd-boot retired only after all checks pass.
