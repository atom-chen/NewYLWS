
====xxtea����========
��Ҫ��װMinGW32 https://sourceforge.net/projects/mingw/files/Installer
��MinGW32�ϰ�װgcc
����xxtea.dll ��python ���ܽű�����:
gcc -shared -Wl,-soname=xxtea.dll -o xxtea.dll -fPIC xxtea.c -std=c99  