export soundspeed, wavelength
export flutelength, toneholelength

"""
  𝑐 = soundspeed(ϑ=25.0)

Calculate the speed of sound in air of temperature ϑ
"""
function soundspeed(ϑ=25.0)
  𝛾 = 1.400            # heat capacity ratio of air
  𝑅 = 8.31446261815324 # molar gas constant (J/mol/K)
  𝑀 = 0.028965369      # mean molar mass of air (kg/mol)
  𝑐 = √(𝛾*𝑅/𝑀 *273.15)*√(1.0 + ϑ/273.15)
  return 𝑐*1000.0 # (to mm/s)
end

"""
  𝜆 = wavelength(𝑓=440.0; ϑ=25.0)

calculate wavelength of given frequency 𝑓 in air of temperature ϑ
"""
function wavelength(𝑓=440.0; ϑ=25.0)
  𝑐 = soundspeed(ϑ)
  𝜆 = 𝑐/𝑓
  return 𝜆
end

"""
  ℓₜ = flutelength(𝑓=440.0; ϑ=25.0, ℓₑ=52.0, ⌀=19.0)

Calculate flute length from embouchure-hole to open-end
  for fundamental frequency 𝑓, temperature ϑ, embouchure correction ℓₑ,
  and open-end bore diameter ⌀
"""
function flutelength(𝑓=440.0; ϑ=25.0, ℓₑ=52.0, ⌀=19.0)
  𝛬 = wavelength(𝑓; ϑ=ϑ)/2
  𝛥ℓₜ = 0.3⌀
  ℓₜ = 𝛬 - ℓₑ - 𝛥ℓₜ
  return ℓₜ
end

"""
ℓₕ = toneholelength(𝑓=440.0; ϑ=25.0, ℓₑ=52.0, ⌀=19.0, 𝑑=9.0, ℎ=3.5, 𝑔=2^(1/12))

Calculate distance from embouchure hole center to tone hole center
  for supplied frequency 𝑓, temperature ϑ, embouchure correction ℓₑ,
  tone-hole bore diameter ⌀, tone-hole height ℎ, tone-hole diameter 𝑑,
  and interval coefficient 𝑔
"""
function toneholelength(𝑓=440.0; ϑ=25.0, ℓₑ=52.0, ⌀=19.0, 𝑑=9.0, ℎ=3.5, 𝑔=2^(1/12))
  𝐺 = 𝑔 - 1
  𝛬 = wavelength(𝑓; ϑ=ϑ)/2
  𝐿 = (ℎ+𝑑) * (⌀/𝑑)^2 - 0.45⌀
  𝑧 = 𝐺/2 * √(1 + 4𝐿/(𝐺*𝛬)) - 𝐺/2
  𝛥ℓₕ = 𝑧 * 𝛬
  ℓₕ = 𝛬 - ℓₑ - 𝛥ℓₕ
  return ℓₕ
end
