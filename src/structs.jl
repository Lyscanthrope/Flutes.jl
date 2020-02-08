
mutable struct Head
  ℓᵩ  # Embouchure correction       (52.0)
  ⌀ₛ  # stop taper bore diameter    (19.0)
end

mutable struct ToneHole
  𝑓  # tone hole frequency
  ⌀  # bore diameter (19.0)
  ℎ  # tone hole height
  𝑑  # tone hole diameter
  𝑔  # interval ratio (𝐺 - 1)
end

mutable struct Flute
  head::Head
  𝜗   # Air temperature             (25.0)
  𝑓ₜ  # Fundamental frequency       (261.6155653)
  ⌀ₜ  # flute end bore diameter     (19.0)
  toneholes::Vector<ToneHole>
end

"""
  𝑭 = createFlute(ℓᵩ=52.0, 𝑓ₜ=261.615565, 𝜗=25.0, ⌀ₜ=19.0)
"""
function createFlute(ℓᵩ=52.0, 𝑓ₜ=261.615565, 𝜗=25.0, ⌀ₜ=19.0)
  head = Head(ℓᵩ, ⌀ₜ)
  return Flute(head, 𝜗, 𝑓ₜ, ⌀ₜ, [])
end

