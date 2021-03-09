/* 
 * FOFOLITO - Sistema Operacional para RaspberryPi
 * Funções responsáveis por fazer a comunicação com a Mailbox0 do RPi
 *
 * Marcos Medeiros
 */
#ifndef __FB_DEV_H__
#define __FB_DEV_H__

#include "types.h"

/* Cálcula o endereço de rasterização de um pixel */
#define __fb_pos(dev, x, y)	(dev->base + ((y * dev->width + x) * (dev->bpp / 8)))

/* Descreve um retângulo */
struct fbdev_rect {
	ushort x;
	ushort y;
	ushort w;
	ushort h;
};

/* Descreve um modo */
struct fbdev_mode {
	ushort width;
	ushort height;
	ushort bpp;
};

struct fbdev_font {
	const char *name;
	uint width;
	uint height;
	const uchar *data;
	uint size;
};

/* Fonte padrão */
const struct fbdev_font *const get_font_vga_8x16();

/* Descreve um dispositivo de framebuffer e seu modo atual */
struct fbdev {
	uint (*modeset)(struct fbdev *, const struct fbdev_mode *);
	uint (*maprgb)(struct fbdev *, uint, uint, uint);
	const char *name;
	ushort width;
	ushort height;
	ushort bpp;
	uint pitch;
	uint size;
	void *base;
};

/* Registra um driver na arvore do sistema */
int fb_register_device(struct fbdev *dev);
void fb_set_mode();
struct fbdev *fb_get_device();
void fb_set_address(void *ptr);

/* Funções genéricas para operações com o framebuffer */
uint fb_generic_maprgb(struct fbdev *dev, uint r, uint g, uint b);
void fb_generic_rectfill(struct fbdev *dev, struct fbdev_rect *rect, uint color);
void fb_generic_scroll(struct fbdev *dev, int px, uint bg);
void fb_generic_drawchar(struct fbdev *dev, const struct fbdev_font *font,
						 int x, int y, char chr, int bg, int fg);
void fb_init();


void fb_rectfill(int x, int y, int w, int h, uint color);
void fb_clear();

#endif/*__FB_DEV_H__*/
