/* 
 * FOFOLITO - Sistema Operacional para RaspberryPi
 * 
 * Emulação de um console sobre um driver de framebuffer
 * Marcos Medeiros
 */

#include "fb.h"
#include "fb_console.h"
#include "errno.h"
#include "types.h"

/* Nosso dispositivo de framebuffer */
struct fbdev *dev = NULL;
static struct fbdev_font *font;

uint cursor_x = 0;
uint cursor_y = 0;
uint console_columns = 0;
uint console_rows = 0;
uint color_fg = 0;
uint color_bg = 0;
uint char_width = 0;
uint char_height = 0;

/* 
 * Inicia um console sobre o framebuffer.
 * É importante notar que é necessário que o fb já esteja iniciado
 */
int fb_console_init()
{
	dev = fb_get_device();
	if (!dev)
		return -ENODEV;

	cursor_x = 0;
	cursor_y = 0;
	font = get_font_vga_8x16();
	console_columns = dev->width / font->width;
	console_rows = (dev->height / font->height) - 2;
	char_width = font->width;
	char_height = font->height;
#if 1
	color_bg = dev->maprgb(dev, 0, 0, 0);
	color_fg = dev->maprgb(dev, 200, 200, 200);
#else
	color_fg = dev->maprgb(dev, 0, 0, 0);
	color_bg = dev->maprgb(dev, 255, 255, 255);
#endif
	struct fbdev_rect r;
	r.x = 0;
	r.y = 0;
	r.w = dev->width;
	r.h = dev->height;
	fb_generic_rectfill(dev, &r, color_bg);
	return -EOK;
}

void fb_console_putc(char chr)
{
	if (!dev)
		return;
	
	switch (chr) {
		case '\n':
			goto _newline;
		case '\t':
			cursor_x = (cursor_x & ~3) + 4;
			if (cursor_x >= console_columns)
				goto _newline;
			break;
		default:
			fb_generic_drawchar(dev, font, cursor_x * char_width, cursor_y * char_height,
							 	chr, color_bg, color_fg);
			/* Pulando a linha */
			if (++cursor_x >= console_columns) {
			_newline:
				cursor_x = 0;
				if (++cursor_y >= console_rows) {
					cursor_y--;

					/* faz a rolagem de uma linha */
					fb_generic_scroll(dev, char_height, color_bg);
				}
			}
	}
}

void fb_setbg(int r, int g, int b)
{
	if (!dev)
		return;

	color_bg = dev->maprgb(dev, r, g, b);
}

void fb_setfg(int r, int g, int b)
{
	if (!dev)
		return;

	color_fg = dev->maprgb(dev, r, g, b);
}

void fb_gotoxy(int x, int y)
{
	if (x >= console_columns)
		x = console_columns - 1;
	if (y >= console_rows)
		y = console_rows - 1;

	cursor_x = x;
	cursor_y = y;
}

void fb_clear_line(int line)
{
	struct fbdev_rect r;
	r.x = 0;
	r.y = line * char_height;
	r.w = dev->width;
	r.h = r.y + char_height;
	fb_generic_rectfill(dev, &r, color_bg);
}

unsigned fb_getcolor(int r, int g, int b)
{
	if (!dev)
		return 0;

	return dev->maprgb(dev, r, g, b);
}

void fb_clear()
{
	struct fbdev_rect r;
	r.x = 0;
	r.y = 0;
	r.w = dev->width;
	r.h = dev->height;
	fb_generic_rectfill(dev, &r, color_bg);
}