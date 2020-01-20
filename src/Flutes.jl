
"""
Parametric Flute Modeling Tool

distances in millimeters
frequencies in Hertz
temperatures in Celsius
time in seconds
"""
module Flutes
    export Flute, createFlute, tubelength, holelength, 𝐺
    include("apply.jl")

    mutable struct Flute
        𝑓ₜ  # Fundamental frequency       (261.6155653)
        𝜗   # Air temperature             (25.0)
        ⌀ᵦ  # stop taper bore diameter    (19.0)
        ⌀ₜ  # flute end bore diameter     (19.0)
        𝛥ℓᵩ # Embouchure correction       (52.0)
    end

    """
      𝐺 = 2^(1/12)

    The constant by which a frequency may be multiplied to result in a
      frequency one semitone higher, using equal temperament tuning.
    """
    𝐺 = 2^(1/12)

    """
        flute = createFlute(𝑓ₜ=261.6155653, 𝜗=25.0, ⌀ₜ=19.0, 𝛥ℓᵩ=52.0)
    """
    function createFlute(𝑓ₜ=261.6155653, 𝜗=25.0, ⌀ₜ=19.0, 𝛥ℓᵩ=52.0)
        return Flute(𝑓ₜ, 𝜗, ⌀ₜ, ⌀ₜ, 𝛥ℓᵩ)
    end

    """
        𝑐 = soundspeed(𝜗=25.0)

    Calculate the speed of sound in air of temperature 𝜗
    """
    function soundspeed(𝜗=25.0)
        𝛾 = 1.400            # heat capacity ratio of air
        𝑅 = 8.31446261815324 # molar gas constant (J/mol/K)
        𝑀 = 0.028965369      # mean molar mass of air (kg/mol)
        𝑐 = √(𝛾 * 𝑅/𝑀 * 273.15) * √(1.0 + 𝜗/273.15)
        round(𝑐; sigdigits=4) * 1000.0 # (to mm/s)
    end

    """
      ℓᵩ = halfwavelength(𝑓=440.0, 𝜗=25.0)

    calculate half of a wavelength of given frequency 𝑓 in air of temperature 𝜗
    """
    function halfwavelength(𝑓=440.0, 𝜗=25.0)
        𝑐 = soundspeed(𝜗)
        ℓᵩ = 𝑐/2𝑓
        round(ℓᵩ; digits=6)
    end

    """
        ℓₜ = tubelength(flute::Flute)

    Calculate tube length from embouchure-hole to open-end for supplied flute struct
    """
    function tubelength(flute::Flute)
        ℓᵩ = halfwavelength(flute.𝑓ₜ, flute.𝜗)
        𝛥ℓₜ = 0.3 * flute.⌀ₜ
        ℓₜ = ℓᵩ - flute.𝛥ℓᵩ - 𝛥ℓₜ
        round(ℓₜ; digits=2)
    end

    """
      ℓₕ = holelength(flute::Flute, 𝑓ₕ=440, ℎₕ=2.5, 𝑑ₕ=7, ⌀ₕ=19.0, 𝑔=(𝐺 - 1))

    Calculate distance from embouchure hole center to tone hole center for supplied frequency 𝑓ₕ,
      tone hole height ℎₕ, tone hole diameter 𝑑ₕ, bore diameter ⌀ₕ and interval ratio 𝑔 (minus one)
    """
    function holelength(flute::Flute, 𝑓ₕ=440, ℎₕ=2.5, 𝑑ₕ=7, ⌀ₕ=19.0, 𝑔=(𝐺 - 1))
        ℓᵩ = halfwavelength(𝑓ₕ, flute.𝜗)
        𝐿 = (ℎₕ + 𝑑ₕ) * (⌀ₕ/𝑑ₕ)^2 - 0.45⌀ₕ
        𝑧 = 𝑔/2 * √(1 + 4𝐿/(𝑔*ℓᵩ)) - 𝑔/2
        𝛥ℓₕ = 𝑧 * ℓᵩ
        ℓₕ = ℓᵩ - flute.𝛥ℓᵩ - 𝛥ℓₕ
        round(ℓₕ; digits=2)
    end
end
