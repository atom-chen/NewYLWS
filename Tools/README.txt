
====xxtea加密========
需要安装MinGW32 https://sourceforge.net/projects/mingw/files/Installer
在MinGW32上安装gcc
编译xxtea.dll 供python 加密脚本调用:
gcc -shared -Wl,-soname=xxtea.dll -o xxtea.dll -fPIC xxtea.c -std=c99  