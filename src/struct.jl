
struct Head
  ℓᵩ
  ℓ₀
  ⌀₀
  ℎ₀
  ℓᵣ
  ⌀ᵣ
  ℎᵣ
  ℓₚ
  𝜃ₚ
  ⌀ₑ
  ℎₑ
  𝑑ₑ
  𝑠ₑ
  𝜓ₑ
  𝜙ₑ
  ℓₛ
  ⌀ₛ
  ℎₛ
  ℓₙ
  ℓₐ
end

struct ToneHole
  𝑓ₕ
  ℓₕ
  ⌀ₕ
  ℎₕ
  𝑑ₕ
  𝜃ₕ
end

struct Flute
  head::Head
  toneholes::Vector<ToneHole>
  𝑓ₜ
  ℓₜ
  ⌀ₜ
  ℎₜ
end

