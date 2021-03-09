#ifndef __TYPES_H__
#define __TYPES_H__

typedef unsigned char uchar;
typedef unsigned short ushort;
typedef unsigned int uint;

typedef volatile unsigned int *const ioaddr;

#define NULL ((void *) 0)

/* Macro para evitar que o compilar nos de avisos sobre variáveis
 * não utilizadas.
 */
#define UNUSED(var)	(void) var


#endif/*__TYPES_H__*/