/* 
 * FOFOLITO - Sistema Operacional para RaspberryPi
 * Funções responsáveis por fazer a comunicação com a Mailbox0 do RPi
 *
 * Marcos Medeiros
 */
#ifndef __FB_CONSOLE_H__
#define __FB_CONSOLE_H__

#include "types.h"
#include "fb.h"

int fb_console_init();
void fb_console_putc(char chr);
void fb_setbg(int r, int g, int b);
void fb_setfg(int r, int g, int b);
void fb_gotoxy(int x, int y);
void fb_clear_line(int line);
unsigned fb_getcolor(int r, int g, int b);

#endif/*__FB_CONSOLE_H__*/
