/*
 * Tenon & mortise using AS568-019 o-rings
 *  (glands scaled 1.5mm above standard)
 */
include <consts.scad>;
use <tools.scad>;

// TODO: externalize all this
// mortise inner bore - 0.925-0.927"
A=25.2;
// piston outer diameter - 0.923-0.922"
C=24.9;
// gland outer diameter - 0.815-0.813"
F=22.2;
// o-ring minor diameter - .067-.073"
CS=1.78;

module mortise(z=0, l=26) {
  lz=(A-19)/2;
  slide(z) difference() {
    hull() {
      post(b=A+4);
      post(z=l/2, b=A+8);
      post(z=l-1-LAYER_HEIGHT, b=28);
      post(z=l-LAYER_HEIGHT, b=26);
    }
    // bore
    bore(b=A, l=l-lz);
    // bevel to flute bore
    bore(z=l-lz, b=A, b2=19, l=lz);
  }
}

module gland(z=0) {
  lz = (C-F)/2;
  slide(z-CS-lz) difference() {
    // piston
    bore(b=C, l=CS+lz);
    // flat
    post(b=F, l=CS);
    // bevel to piston
    post(z=CS, b=F, b2=C, l=lz);
  }
}

module tenon(z=0, l=26) {
  bb=19+NOZZLE_DIAMETER;
  lz=(C-bb)/2;
  slide(z) difference() {
    union() {
      post(b=C, l=l-lz);
      post(z=l-lz, b=C, b2=bb, l=lz);
    }
    gland(z=l-lz-LAYER_HEIGHT);
    gland(z=(l-lz)/2);
    bore(b=19, l=26);
  }
}

tenon();
mortise();
