// Based on darkriscv
// https://github.com/darklife/darkriscv/blob/master/src/stdio.c
#include "main.h"

unsigned __umulsi3(unsigned x,unsigned y)
{
    unsigned acc;

    if(x<y) { unsigned z = x; x = y; y = z; }
    
    for(acc=0;y;x<<=1,y>>=1) if (y & 1) acc += x;

    return acc;
}

int __mulsi3(int x, int y)
{
    unsigned acc,xs,ys;
    
    if(x<0) { xs=1; x=-x; } else xs=0;
    if(y<0) { ys=1; y=-y; } else ys=0;

    acc = __umulsi3(x,y);
    
    return xs^ys ? -acc : acc;
}

unsigned __udiv_umod_si3(unsigned x,unsigned y,int opt)
{
    unsigned acc,aux;

    if(!y) return 0;

    for(aux=1,acc=y;acc<x;aux<<=1,acc<<=1,y=acc);
    for(acc=0;x&&aux;aux>>=1,y>>=1) if(y<=x) x-=y,acc+=aux;

    return opt ? acc : x;
}

int __udivsi3(int x, int y)
{
    return __udiv_umod_si3(x,y,1);
}

int __umodsi3(int x,int y)
{
    return __udiv_umod_si3(x,y,0);
}

int __div_mod_si3(int x,int y,int opt)
{
    unsigned acc,xs,ys;

    if(!y) return 0;

    if(x<0) { xs=1; x=-x; } else xs=0;
    if(y<0) { ys=1; y=-y; } else ys=0;

    acc = __udiv_umod_si3(x,y,opt);

    if(opt) return xs^ys ? -acc : acc;
    else    return xs    ? -acc : acc;
}

int __divsi3(int x, int y)
{
    return __div_mod_si3(x,y,1);
}

int __modsi3(int x,int y)
{
    return __div_mod_si3(x,y,0);
}



char *memset(char *dptr, int c, int len)
{
    char *ret = dptr;
    
    while(len--) *dptr++ = c;
    
    return ret;
}

void memcpy(void *dst, const void *src, unsigned size)
{
    const char *psrc = (char *) src;
    char *pdst = (char *) dst;
    unsigned k = 0;
    while (k < size) {
        *pdst++ = *psrc++;
        k++;
    }
}

struct xs32_state
{
    uint32_t a;
};

static struct xs32_state _xss __attribute__((aligned(4))) = { 0 };

uint32_t xorshift32(struct xs32_state *state)
{
    uint32_t x = state->a;
    x ^= x << 13;
    x ^= x >> 17;
    x ^= x << 5;
    state->a = x;
    return state->a;
}


int rand()
{
    return xorshift32(&_xss);
}

void srand(int seed)
{
    //_xss.x = _xss.a;
    _xss.a = seed;
}

int getseed()
{
    return _xss.a;
}