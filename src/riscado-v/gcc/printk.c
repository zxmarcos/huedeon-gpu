/* 
 * FOFOLITO - Sistema Operacional para RaspberryPi
 * Implementação da função printk
 *
 * Marcos Medeiros
 */
#include <stdarg.h>
#include "fb_console.h"
#include "types.h"
 
/* Número máximo de digitos que um número decimal pode ter 
 * 000.000.000.000
 */
#define DECIMAL_MAX	12

const char *const hex_chars[2] = { 
		"0123456789ABCDEF",
		"0123456789abcdef"
};


/* Emite um caracter no console */
void putk(unsigned c)
{
	/* TODO: Implementar o log em buffer */
	fb_console_putc(c);
}

/* Emite um valor em hexadecimal */
void print_hex(unsigned val, unsigned hcase)
{
	/* escolhe a tabela de caracters */
	const char * const table = hex_chars[hcase ? 1 : 0];
	int i = 32;
	int k = 7;
	
	while (i >= 4) {
		int idx = (val >> (k * 4)) & 0xF;
		char c = table[idx];
		putk(c);
		k--;
		i -= 4;
	}
}

/* Emite um valor em decimal */
void print_decimal(unsigned val)
{
	unsigned digits[DECIMAL_MAX];

	memset(digits, 0, DECIMAL_MAX * sizeof(unsigned));

	int i = 0;

	/* Decompõe o valor em digitos da direita para esquerda */
	do {
		digits[i] = 0x30 + (val % 10);
		val /= 10;
		i++;
	} while ((val != 0) && (i < DECIMAL_MAX));

	/* Vamos começar do ultimo digito e imprimir da esquerda para direita */
	i--;
	while (i >= 0) {
		putk(digits[i]);
		i--;
	}
}

/* Emite um valor em binário */
void print_binary(unsigned val, int size)
{
	if (!size)
		return;
	size -= 1;

	/* Nosso tamanho máximo é de 32bits */
	if (size > 32)
		size = 32;
	
	int i = size;
	while (i >= 0) {
		putk(0x30 + ((val >> i) & 1));
		i--;
	}
}

/* Implementação básica da função printk */
void printk(const char *fmt, ...)
{
	va_list va;
	va_start(va, fmt);

	while (*fmt) {
		if (*fmt != '%') {
			putk(*fmt);
			fmt++;
		} else {
			fmt++;
			if (*fmt == '%') {
				putk(*fmt);
				fmt++;
			} else
			if (*fmt == 'd') {
				print_decimal(va_arg(va, int));
				fmt++;
			} else
			if (*fmt == 'x') {
				print_hex(va_arg(va, int), 0);
				fmt++;
			} else
			if (*fmt == 'X') {
				print_hex(va_arg(va, int), 1);
				fmt++;
			} else
			if (*fmt == 's') {
				printk(va_arg(va, const char *));
				fmt++;
			} else
			if (*fmt == 'b') {
				int size = 0;
				fmt++;
				if (*fmt == 'b')
					size = 8;
				else
				if (*fmt == 'w')
					size = 16;
				else
				if (*fmt == 'd')
					size = 32;
				else {
					fmt -= 2;
					size = 32;
				}
				fmt++;
				print_binary(va_arg(va, int), size);
			}
		}
	}
	va_end(va);
}
