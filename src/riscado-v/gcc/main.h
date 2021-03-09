#pragma once

#define MAX(a,b) ((a)>(b)?(a):(b))
#define MIN(a,b) ((a)<(b)?(a):(b))

typedef unsigned int uint32_t;
typedef int int32_t;
typedef unsigned char uint8_t;
typedef char int8_t;
typedef unsigned short uint16_t;
typedef short int16_t;

int rand();
void srand(int seed);
int getseed();

void putk(unsigned c);
void print_hex(unsigned val, unsigned hcase);
void print_decimal(unsigned val);
void print_binary(unsigned val, int size);
void printk(const char *fmt, ...);
int main();
