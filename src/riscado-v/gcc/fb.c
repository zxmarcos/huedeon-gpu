/* 
 * FOFOLITO - Sistema Operacional para RaspberryPi
 *
 * Marcos Medeiros
 */
#include "fb.h"
#include "errno.h"
#include "types.h"

struct fbdev const* default_fb = NULL;

struct fbdev riscv_fbdev = {
	.name = "riscv_fb",
	.maprgb = fb_generic_maprgb,
	.width = 320,
	.height = 240,
	.bpp = 16,
	.pitch = 320*2,
	.size = 320*240*2,
	.base = ((ushort*)0x200000)
};

void fb_init()
{
	riscv_fbdev.name = "riscv_fb";
	riscv_fbdev.maprgb = fb_generic_maprgb;
	riscv_fbdev.width = 320;
	riscv_fbdev.height = 240;
	riscv_fbdev.bpp = 16;
	riscv_fbdev.pitch = 320*2;
	riscv_fbdev.size = 320*240*2;
	riscv_fbdev.base = ((ushort*)0x200000);
	fb_register_device(&riscv_fbdev);
}

void fb_set_address(void *ptr)
{
	riscv_fbdev.base = (ushort*) ptr;
}

/* Registra um framebuffer na arvore de dispositivos do sistema */
int fb_register_device(struct fbdev *dev)
{
	default_fb = dev;
	return -EOK;
}

void fb_set_mode()
{
	/* Se existir algum dispositivo de framebuffer */
	if (default_fb)
		default_fb->modeset(default_fb, NULL);
}

struct fbdev *fb_get_device()
{
	return default_fb;
}

/* Mapeia uma cor */
uint fb_generic_maprgb(struct fbdev *dev, uint r, uint g, uint b)
{
	uint color = 0;
	if (!dev)
		return ~0;

	/* Cálcula o valor para cada BPP */
	switch (dev->bpp) {
		/* No padrão RGB565 */
		case 16:
			r = (32 * r) / 256;
			g = (64 * g) / 256;
			b = (32 * b) / 256;
			color = ((r & 0x1F) << 11) | ((g & 0x3F) << 5) | (b & 0x1F);
			break;
		case 24:
		/* sem suporte para canais alpha */
		case 32:
			color = ((r & 0xFF) << 16) | ((g & 0xFF) << 8) | (b & 0xFF);
			break;

	}

	return color;
}

void fb_rectfill(int x, int y, int w, int h, uint color)
{
	struct fbdev_rect r;
	r.x=x;
	r.y=y;
	r.w=w;
	r.h=h;
	fb_generic_rectfill(default_fb, &r, color);
}

void fb_generic_rectfill(struct fbdev *dev, struct fbdev_rect *rect, uint color)
{
	int x = rect->x;
	int y = rect->y;
	int w = rect->w;
	int h = rect->h;
	int ly = 0;
	int lx = 0;

	/* Verifica se as coordenadas estão fora do framebuffer */
	if (x >= dev->width || y >= dev->height)
		return;

	if ((x + w) >= dev->width)
		w = dev->width - x;
	if ((y + h) >= dev->height)
		h = dev->height - y;

	/* cálcula os valores finais de x e y */
	ly = y + h;
	lx = x + w;

	switch (dev->bpp) {
		case 16: {
			while (y < ly)  {
				/* reinicia o valor de x inicial */
				x = rect->x;
				ushort *ptr = __fb_pos(dev, x, y);
				while (x < lx) {
					*ptr++ = color;
					x++;
				}
				y++;
			}
			break;
		}
		case 32: {
			while (y < ly)  {
				/* reinicia o valor de x inicial */
				x = rect->x;
				uint *ptr = __fb_pos(dev, x, y);
				while (x < lx) {
					*ptr++ = color;
					x++;
				}
				y++;
			}
			break;
		}
	}
}

void fb_generic_scroll(struct fbdev *dev, int px, uint bg)
{
	void *dst = dev->base;
	void *src = __fb_pos(dev, 0, px);
	uint size = dev->size - (px * dev->pitch);
	memcpy(dst, src, size);

	struct fbdev_rect r;
	r.x = 0;
	r.y = dev->height - px;
	r.w = dev->width;
	r.h = px;
	fb_generic_rectfill(dev, &r, bg);
}

void fb_generic_drawchar(struct fbdev *dev, const struct fbdev_font *const font,
						 int x, int y, char chr, int bg, int fg)
{
	/* Verifica se está fora do framebuffer */
	if (x >= dev->width || y >= dev->height)
		return;

	int ix = x;
	
	/* Cálcula as posições finais */
	int lx = x + font->width;
	int ly = y + font->height;

	int line = 0;

	if (lx >= dev->width)
		lx = dev->width;
	if (ly >= dev->height)
		ly = dev->height;

	while (y <= ly) {
		x = ix;
		ushort *ptr = __fb_pos(dev, x, y);

		unsigned char bits = font->data[(chr&0xFF) * font->height + line];
		while (x <= lx) {
			if (bits & 0x80)
				*ptr = fg;
			else
				*ptr = bg;
			bits <<= 1;
			ptr++;
			x++;
		}
		y++;
		line++;
	}
}