/*
 * Tenon & mortise using AS568-019 o-rings
 *  (glands scaled 1.5mm above standard)
 */
include <consts.scad>;
use <tools.scad>;

// mortise inner bore - 0.925-0.927"
A=25.05;
// piston outer diameter - 0.923-0.922"
C=24.92;
// gland outer diameter - 0.815-0.813"
F=22.2;
// o-ring minor diameter - .067-.073"
CS=1.78;
TenonOuter=A+3.2;
TenonLip=A+(TenonOuter-A)/3;

module mortise(z=0, l=26) {
  lz=(A-19)/2;
  lc=(TenonOuter-26)/2;
  slide(z) difference() {
    union() {
      shell(b=TenonOuter, l=l-lc);
      chamfer(z=l, b=TenonOuter, b2=26, fromend=true);
    }
    // bore
    bore(b=A, l=l-lz);
    // bevel to flute bore
    bore(z=l-lz, b=A, b2=19, l=lz);
    // entrance lip
    bore(b=TenonLip, b2=A, l=(TenonLip-A)/2);
  }
}

module gland(z=0, fromend=false) {
  lz=(C-F)/2;
  zz = !fromend ? z : z-(2*(lz+CS));
  slide(zz) difference() {
    // piston
    bore(b=C, l=CS+lz);
    // flat
    shell(b=F, l=CS);
    // bevel to piston
    chamfer(z=CS, b=F, b2=C);
  }
}

module tenon(z=0, l=26) {
  lz=(C-19)/2;
  ll=l+LAYER_HEIGHT;
  slide(z) difference() {
    union() {
      shell(b=C, l=ll-lz);
      chamfer(z=ll-lz, b=C, b2=19);
    }
    bore(b=19, l=ll);
    gland(z=ll, fromend=true);
    gland(z=6);
  }
}

tenon();
mortise();
