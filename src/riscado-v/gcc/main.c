#include "main.h"
#include "fb.h"
#include "fb_console.h"


//=======================================================
//  GPU stuff
//=======================================================
static int hw_accel = 0;
static int enable_vsync = 0;

typedef int32_t fixed_point;
// Fixed-point arithm
#define FIXPT_FRACTION_BITS   10
#define FIXPT_INT(n)          ((n) << FIXPT_FRACTION_BITS)
#define FIXPT_DIVISOR         (FIXPT_INT(1))
#define FIXPT(f)              ((fixed_point)(f * (float)FIXPT_DIVISOR))

// Gpu registers
#define VRAM                  ((volatile uint16_t*)0x200000)
#define VRAM_PAGE_0           0
#define VRAM_PAGE_1           (320*240)
#define GPU_IO                ((volatile uint32_t*)0x300000)
#define GPU_REG_RESET         0
#define GPU_REG_CONTROL       1
#define GPU_REG_DRAW          2
#define GPU_REG_V1_X          3
#define GPU_REG_V1_Y          4
#define GPU_REG_V1_Z          5
#define GPU_REG_V1_COLOR      6
#define GPU_REG_V1_UV         7
#define GPU_REG_V2_X          8
#define GPU_REG_V2_Y          9
#define GPU_REG_V2_Z          10
#define GPU_REG_V2_COLOR      11
#define GPU_REG_V2_UV         12
#define GPU_REG_V3_X          13
#define GPU_REG_V3_Y          14
#define GPU_REG_V3_Z          15
#define GPU_REG_V3_COLOR      16
#define GPU_REG_V3_UV         17
#define GPU_REG_DRAW_OFFSET   18
#define GPU_REG_DISP_OFFSET   19
#define TEX_UV(u,v)           (((u)&0xFFFF)<<16)|((v)&0xFFFF)

#define GPU_VSYNC             0x80000000
#define GPU_BUSY              0x00000001

#define GPU_CONTROL_VERTEX_COLOR_ENABLE 1

#define IOSTATUS              ((volatile uint32_t*)0x80000000)

static int vram_current_page;



struct triangle {
  fixed_point   v1_x;
  fixed_point   v1_y;
  fixed_point   v1_z;
  uint32_t      v1_color;
  uint32_t      v1_uv;

  fixed_point   v2_x;
  fixed_point   v2_y;
  fixed_point   v2_z;
  uint32_t      v2_color;
  uint32_t      v2_uv;

  fixed_point   v3_x;
  fixed_point   v3_y;
  fixed_point   v3_z;
  uint32_t      v3_color;
  uint32_t      v3_uv;
};

void draw_triangle(const struct triangle * tri);

void draw_quad(int x, int y, int w, int h, uint32_t color)
{
  struct triangle t1, t2;
  t1.v1_x = FIXPT_INT(x);
  t1.v1_y = FIXPT_INT(y);
  t1.v1_uv = 0;
  t1.v1_color = color;

  t1.v2_x = FIXPT_INT(x);
  t1.v2_y = FIXPT_INT(y+h);
  t1.v2_uv = 0;
  t1.v2_color = color;

  t1.v3_x = FIXPT_INT(x+w);
  t1.v3_y = FIXPT_INT(y+h);
  t1.v3_uv = 0;
  t1.v3_color = color;

  t2.v1_x = FIXPT_INT(x);
  t2.v1_y = FIXPT_INT(y);
  t2.v1_uv = 0;
  t2.v1_color = color;
  t2.v2_x = FIXPT_INT(x+w);
  t2.v2_y = FIXPT_INT(y+h);
  t2.v2_uv = 0;
  t2.v2_color = color;
  t2.v3_x = FIXPT_INT(x+w);
  t2.v3_y = FIXPT_INT(y);
  t2.v3_uv = 0;
  t2.v3_color = color;

  draw_triangle(&t1);
  draw_triangle(&t2);
}


void wait_vsync()
{
  while (~GPU_IO[0] & GPU_VSYNC);
}

void wait_for_complete()
{
  while (GPU_IO[0] & GPU_BUSY);
}


void draw_triangle(const struct triangle * tri)
{
  const uint32_t *data = (uint32_t*)tri;

  GPU_IO[GPU_REG_RESET] = 1;
  // enable vertex color
  GPU_IO[GPU_REG_CONTROL] = GPU_CONTROL_VERTEX_COLOR_ENABLE;

  int write_reg = GPU_REG_V1_X;
  for (int i = 0; i < 15; i++) {
    GPU_IO[write_reg] = data[i];
    write_reg++;
  }
  // draw.
  GPU_IO[GPU_REG_DRAW] = 1;
  wait_for_complete();
}

static const struct triangle clear_screen_tri[2] = {
  /*            V1                                     V2                                  V3                    */
  { FIXPT_INT(0),FIXPT_INT(0),0,0,0,   FIXPT_INT(  0),FIXPT_INT(240),0,0,0,   FIXPT_INT(320),FIXPT_INT(240),0,0,0 },
  { FIXPT_INT(0),FIXPT_INT(0),0,0,0,   FIXPT_INT(320),FIXPT_INT(240),0,0,0,   FIXPT_INT(320),FIXPT_INT(  0),0,0,0 },
};

void clear_screen()
{
  for (int i = 0; i < 2; i++) {
    draw_triangle(&clear_screen_tri[i]);
  }
}



void swap_buffers()
{
  if (enable_vsync)
    wait_vsync();
  vram_current_page ^= 1;
  GPU_IO[GPU_REG_DRAW_OFFSET] = vram_current_page ? VRAM_PAGE_0 : VRAM_PAGE_1;
  GPU_IO[GPU_REG_DISP_OFFSET] = vram_current_page ? VRAM_PAGE_1 : VRAM_PAGE_0;

  uint8_t *ptr = &VRAM[vram_current_page ? VRAM_PAGE_0 : VRAM_PAGE_1];
  fb_set_address(ptr);
}


//=======================================================
//  MISC stuff
//=======================================================
struct animator {
  unsigned max;
  unsigned min;
  unsigned order;
  unsigned speed;
  unsigned *value;
};

void init_animator(struct animator *a, unsigned min, unsigned max, unsigned speed, unsigned *value)
{
  a->min = min;
  a->max = max;
  a->speed = speed;
  a->value = value;
  a->order = 0;
}

void update_animator(struct animator *a)
{
  if (!a->order) {
    *a->value += a->speed;
    if (*a->value >= a->max) {
      a->order ^= 1;
    }
  } else {
    *a->value -= a->speed;
    if (*a->value <= a->min) {
      a->order ^= 1;
    }
  }
}


//=========================================================
//  DOOM FIRE renderer with soft and hardware acceleration
//=========================================================
#define TILE_W  10
#define TILE_H  10
#define WIDTH   (320/TILE_W)
#define HEIGHT  (240/TILE_H)
#define COLORS  37


uint16_t pallete[COLORS];

uint16_t rgb565(uint8_t r8, uint8_t g8, uint8_t b8)
{
  uint16_t b5 = ( b8 >> 3) & 0x1f;
  uint16_t g6 = ((g8 >> 2) & 0x3f) << 5;
  uint16_t r5 = ((r8 >> 3) & 0x1f) << 11;

    return (r5 | g6| b5);
}

unsigned char fire[WIDTH * HEIGHT];
static const unsigned char pallete_rgb[COLORS][3] = {
    {  7,  7,  7},
    { 31,  7,  7},
    { 47, 15,  7},
    { 71, 15,  7},
    { 87, 23,  7},
    {103, 31,  7},
    {119, 31,  7},
    {143, 39,  7},
    {159, 47,  7},
    {175, 63,  7},
    {191, 71,  7},
    {199, 71,  7},
    {223, 79,  7},
    {223, 87,  7},
    {223, 87,  7},
    {215, 95,  7},
    {215, 95,  7},
    {215,103, 15},
    {207,111, 15},
    {207,119, 15},
    {207,127, 15},
    {207,135, 23},
    {199,135, 23},
    {199,143, 23},
    {199,151, 31},
    {191,159, 31},
    {191,159, 31},
    {191,167, 39},
    {191,167, 39},
    {191,175, 47},
    {183,175, 47},
    {183,183, 47},
    {183,183, 55},
    {207,207,111},
    {223,223,159},
    {239,239,199},
    {255,255,255}
};


void reset_fire()
{
  for (int y = 0; y < HEIGHT-1; y++) {
    for (int x = 0; x < WIDTH; x++) {
      fire[y * WIDTH + x] = 0;
    }
  }
  for (int x = 0; x < WIDTH; x++) {
    fire[(HEIGHT-1)*WIDTH + x] = COLORS-1;
  }
}

void updateFire(int index)
{
  int below = index + WIDTH;
  if (below >= HEIGHT*WIDTH)
      return;

  int decay = rand() & 3;
  int below_intensity = fire[below] - decay;
  int intensity = below_intensity >= 0 ? below_intensity : 0;

  int nidx = index - decay;
  if (nidx >= 0 && nidx < HEIGHT*WIDTH)
    fire[nidx] = intensity;
}



void render()
{
  for (int y = 0; y < HEIGHT; y++) {
    for (int x = 0; x < WIDTH; x++) {
      int color_index = fire[y * WIDTH + x];

      if (hw_accel) {
        if (color_index < COLORS) {
          uint8_t *rgb = &pallete_rgb[color_index];
  
          uint32_t r = rgb[0];
          uint32_t g = rgb[1];
          uint32_t b = rgb[2];
  
          uint32_t color = (r << 16) | (g << 8) | b;
          draw_quad(x*TILE_W,y*TILE_H,TILE_W,TILE_H, color);
        } else {
          draw_quad(x*TILE_W,y*TILE_H,TILE_W,TILE_H, 0);
        }

      } else {
        if (color_index < COLORS) {
            fb_rectfill(x*TILE_W,y*TILE_H,TILE_W,TILE_H, pallete[color_index]);
        } else {
            fb_rectfill(x*TILE_W,y*TILE_H,TILE_W,TILE_H, 0);
        }
      }
    }
  }
}

void propagate_fire()
{
  for (int x = 0; x < WIDTH; x++) {
    for (int y = 0; y < HEIGHT; y++) {
      updateFire(y*WIDTH+x);
    }
  }
  render();
}

void setup()
{
  for (int i = 0; i < COLORS; i++) {
    pallete[i] = rgb565(pallete_rgb[i][0],pallete_rgb[i][1],pallete_rgb[i][2]);
  }

  reset_fire();
}



//=======================================================
// ...
//=======================================================
int main() {
  fb_init();
  fb_console_init();
  srand(~0);

  vram_current_page = 0;
  swap_buffers();

  unsigned x1 = 0;
  unsigned x2 = 0;
  unsigned x3 = 100;
  unsigned y1 = 0;
  unsigned y2 = 200;
  unsigned y3 = 200;
  
  struct animator x1_a;
  struct animator x3_a;
  struct animator y2_a;
  init_animator(&x1_a, 0, 320, 1, &x1);
  init_animator(&x3_a, 100, 320, 2, &x3);
  init_animator(&y2_a, 50, 240, 4, &y2);

  struct triangle triangles[2];

  triangles[0].v1_color = 0x00FF0000;
  triangles[0].v2_color = 0x0000FF00;
  triangles[0].v3_color = 0x000000FF;
  triangles[0].v1_uv    = TEX_UV(0,0);
  triangles[0].v2_uv    = TEX_UV(0,128);
  triangles[0].v3_uv    = TEX_UV(128,128);
  triangles[1].v1_color = 0x00770000;
  triangles[1].v2_color = 0x00007700;
  triangles[1].v3_color = 0x00000077;
  triangles[1].v1_uv    = TEX_UV(128,128);
  triangles[1].v2_uv    = TEX_UV(0,128);
  triangles[1].v3_uv    = TEX_UV(0,0);

  setup();

  int counter = 0;
  hw_accel = 0;
  for(;;) {

    uint32_t st = *IOSTATUS;
    hw_accel = st & 1;
    enable_vsync = st & 2;
    
    update_animator(&x1_a);
    update_animator(&x3_a);
    update_animator(&y2_a);

    unsigned b_x1 = x1;
    unsigned b_y1 = y1;

    unsigned b_x2 = x3;
    unsigned b_y2 = y3;
    
    unsigned b_x3 = x3 + MAX(x3,x2)-MIN(x3,x2);
    unsigned b_y3 = y3 + (MAX(y3,y2)-MIN(y3,y2))/2;
    

    clear_screen();
    propagate_fire();

    fb_gotoxy(0,0);
    printk("Huestation: riscado-v + huedeon\n");
    printk("%d ", counter);
    if (hw_accel)
      printk("GPU");
    else
      printk("CPU");

    triangles[0].v1_x = FIXPT_INT(x1);
    triangles[0].v1_y = FIXPT_INT(y1);
    triangles[0].v2_x = FIXPT_INT(x2);
    triangles[0].v2_y = FIXPT_INT(y2);
    triangles[0].v3_x = FIXPT_INT(x3);
    triangles[0].v3_y = FIXPT_INT(y3);

    triangles[1].v1_x = FIXPT_INT(b_x1);
    triangles[1].v1_y = FIXPT_INT(b_y1);
    triangles[1].v2_x = FIXPT_INT(b_x2);
    triangles[1].v2_y = FIXPT_INT(b_y2);
    triangles[1].v3_x = FIXPT_INT(b_x3);
    triangles[1].v3_y = FIXPT_INT(b_y3);

    draw_triangle(&triangles[0]);
    draw_triangle(&triangles[1]);
    swap_buffers();
    ++counter;
  }
  return 0;
}