
use <header.scad>

module headjoint() {
  slide({{ℓ₀}}) {
    difference() {
      // outer shell
      union() {
        // tube
        shell(z=-{{ℓ₀}}, b={{⌀₀}}, l={{ℓ₀}}+{{ℓₐ}}-{{ℓₙ}});
        // tenon
        shell(z={{ℓₐ}}-{{ℓₙ}}, b={{⌀ₛ}}+{{ℎₛ}}, l={{ℓₙ}});
        // lip-plate
        plate(d1={{⌀₀}}, d2={{⌀ₑ}}+2*{{ℎₑ}}, l={{𝑑ₚ}});
      }
      // bore
      union() {
        // taper
        hull() {
          // reflector plate
          bore(z=-{{ℓᵣ}}, b={{⌀ᵣ}});
          // embouchure bore
          bore(z=-{{𝑠ₑ}}/2, b={{⌀ₑ}}, l={{𝑠ₑ}});
          // stationary point
          bore(z={{ℓₛ}}, b={{⌀ₛ}});
        }
        // cylindrical section
        bore(z={{ℓₛ}}, b={{⌀ₛ}}, l={{ℓₐ}}-{{ℓₛ}});
      }
      // embouchure hole
      hole(b={{⌀ₑ}}, h={{ℎₑ}}, d={{𝑑ₑ}}, s={{𝑠ₑ}}, r={{𝜃ₑ}}, u={{𝜓ₑ}}, o={{𝜙ₑ}});
    }
  }
}

headjoint();
