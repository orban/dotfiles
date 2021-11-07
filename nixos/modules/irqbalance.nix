{ config, lib, ... }:
let
  isVM = lib.any (mod: mod == "xen-blkfront" || mod == "virtio_console") config.boot.initrd.kernelModules;
in {
  # Pointless in vms or containers and better managed by the host.
  # Also don't enable on laptop's as it might increase energy consumption.
  services.irqbalance.enable = !(config.boot.isContainer || isVM || config.services.tlp.enable);
}