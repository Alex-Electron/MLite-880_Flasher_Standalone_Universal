# Firmware directories

- `MLite-880/` contains firmware for the MLite-880 receiver. The MLite-880 command-line scripts and web flasher list files from this directory only.
- `DSP4/` is reserved for future DSP4 releases. Do not place a DSP4 image in `MLite-880/` or select an MLite-880 image for a DSP4 receiver.

The model must be selected explicitly before adding DSP4 images to a shared web interface. STM32 DFU alone does not reliably identify the receiver model.
