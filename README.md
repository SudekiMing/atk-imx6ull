# atk-imx6ull

## Introduction

The I.MX6U-ALPHA/Mini development board produced by ALIENTEK is used here. ALPHA is a full-featured development board, while Mini is a simplified version. Both of these are Cortex-A7 development platforms based on NXP's I.MX6ULL, with abundant onboard resources, making them very suitable for engineering advanced embedded Linux development who have previously studied Cortex-M core microcontrollers (such as STM32).

I adapted the buildroot version for the I.MX6U-ALPHA/Mini development board and compiled a usable boot image with one command.

Official Gitee documentation and source code reference: https://gitee.com/GuangzhouXingyi



## Requirements

You can compile this board using Ubuntu 20.04, and some necessary dependency packages need to be installed.

```shell
sudo apt install libncurses-dev openssl libssl-dev libghc-gnutls-dev
pip3 install importlib-resources
```



## Quickstart

### Clone

```shell
git clone https://github.com/SudekiMing/atk-imx6ull
```

### Build

```shell
cd atk-imx6ull
make imx6ull_atk_defconfig
make
```

### Startup

- Startup by `balenaEtcher` tool burn image `output/images/sdcard.img`  to SDcard.

- Support cmd burn to emmc.

```shell
# 1.SDcard Startup
# 2.execute cmd
/opt/emmc_update
```



## License
atk-imx6ull is licensed under GPL-2.0

