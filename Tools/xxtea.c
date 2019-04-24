#include <stdio.h>
#include <stdint.h>

//#define DELTA 0x9e3779b9
#define DELTA 0x9ebca9b9
#define MX (((z>>5^y<<2) + (y>>3^z<<4)) ^ ((sum^y) + (key[(p&3)^e] ^ z)))
 
void xxtea_enc(char *data, int len) {
    int n = len/sizeof(uint32_t); 
    if (n <= 0)
    {
        return;
    }
    uint32_t const key[4] = { 0xBEDC, 0x32fb, 0xf3ad, 0xe24f, };
    uint32_t *v = (uint32_t*)data;

    uint32_t y, z, sum;
    unsigned p, rounds, e;

    rounds = 6 + 52/n;
    sum = 0;
    z = v[n-1];
    do
    {
        sum += DELTA;
        e = (sum >> 2) & 3;
        for (p=0; p<n-1; p++)
        {
            y = v[p+1];
            z = v[p] += MX;
        }
        y = v[0];
        z = v[n-1] += MX;
        //printf("e %d , y %u z %u, rounds %d \n", e, y, z, rounds);
    }
    while (--rounds);
}

void xxtea_dec(char *data, int len) {
    int n = len/sizeof(uint32_t); 
    if (n <= 0)
    {
        return;
    }
    uint32_t const key[4] = { 0xBEDC, 0x32fb, 0xf3ad, 0xe24f, };
    uint32_t *v = (uint32_t*)data;

    uint32_t y, z, sum;
    unsigned p, rounds, e;

    rounds = 6 + 52/n;
    sum = rounds*DELTA;
    y = v[0];
    do
    {
        e = (sum >> 2) & 3;
        for (p=n-1; p>0; p--)
        {
            z = v[p-1];
            y = v[p] -= MX;
        }
        z = v[n-1];
        y = v[0] -= MX;
        sum -= DELTA;
    }
    while (--rounds);
}
