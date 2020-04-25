export FluteConstraint, ToneHoleConstraint
export optimal, createflute, addtonehole!
using Optim
using Statistics

struct FluteConstraint
  𝑓  # lowest frequency
  holes
end

struct ToneHoleConstraint
  𝑓  # hole frequency
  𝑑₋ # min diameter
  𝑑₊ # max diameter
  𝑝₋ # min separation
  𝑝₊ # max separation
end

function addtonehole!(flute::FluteConstraint, 𝑓; 𝑑₋=2.0, 𝑑₊=9.0, 𝑝₋=15.0, 𝑝₊=40.0)
  push!(flute.holes, ToneHoleConstraint(𝑓, 𝑑₋, 𝑑₊, 𝑝₋, 𝑝₊))
end

function createflute(𝑓)
  return FluteConstraint(𝑓, [])
end

# error function factory (constraints)
function mkerrfn(flute::FluteConstraint)
  # list of frequencies in descending pitch
  𝒇 = map(𝒉->𝒉.𝑓, flute.holes); push!(𝒇, flute.𝑓)
  𝑯 = 1:length(flute.holes)
  function errfn(𝒅)
    𝑒 = 0.0 # error result
    ℓₚ = 0.0 # location of previous hole, or embouchure
    𝛥ℓᵥ = 0.0 # closed-hole correction
    𝑑mean = mean(𝒅)
    for h in 𝑯  # body->foot order
      # for each tonehole calculate error based on preferences
      𝒉 = flute.holes[h]
      𝑓 = 𝒉.𝑓 # open hole frequency
      𝑓ₜ = 𝒇[h+1] # closed hole frequency
      𝑑ₕ = 𝒅[h] # proposed hole diameter
      ℓₕ = toneholelength(𝑓; 𝑓ₜ=𝑓ₜ, 𝑑=𝑑ₕ, 𝛥ℓᵥ=𝛥ℓᵥ) # resulting location
      # deviation from reachable
      𝛬crowd = ℓₚ - ℓₕ + 𝒉.𝑝₋ # positive if location below min
      𝛬stretch = ℓₕ - ℓₚ - 𝒉.𝑝₊ # positive if location above max
      𝛬reach = max(𝛬crowd, 0.0, 𝛬stretch)
      # deviation from max hole diameter (prefer larger diameters)
      𝛬big = abs(toneholelength(𝑓; 𝑓ₜ=𝑓ₜ, 𝑑=𝒉.𝑑₊, 𝛥ℓᵥ=𝛥ℓᵥ) - ℓₕ)
      # deviation from mean hole diameter (prefer average diameters)
      𝛬avg = abs(toneholelength(𝑓; 𝑓ₜ=𝑓ₜ, 𝑑=𝑑mean, 𝛥ℓᵥ=𝛥ℓᵥ) - ℓₕ)
      # sum weighted errors (heavy weight on reachable locations)
      𝑒 += 2𝛬reach^2 + 𝛬big + 𝛬avg
      # calculate increased correction for next loop
      𝛥ℓᵥ += closedholecorrection(𝒉.𝑓; 𝑓ₜ=𝑓ₜ, 𝑑=𝑑ₕ, 𝛥ℓᵥ=𝛥ℓᵥ)
      # next loop use this hole as the previous hole
      ℓₚ = ℓₕ
    end
    return 𝑒
  end
  return errfn
end

function minbox(flute::FluteConstraint)
  𝒅₋ = map(𝒉->𝒉.𝑑₋, flute.holes)
  𝒅₊ = map(𝒉->𝒉.𝑑₊, flute.holes)
  𝒅₀ = map(𝒅->𝒅*0.9, (𝒅₊-𝒅₋)) + 𝒅₋
  return (𝒅₋, 𝒅₊, 𝒅₀)
end

function optimal(flute)
  # minimize error function
  errfn = mkerrfn(flute)
  # box-constrained, initial parameters
  lower, upper, initial = minbox(flute)
  # particle swarm optimization
  result = optimize(errfn, initial,
                    ParticleSwarm(lower, upper, length(initial)),
                    Optim.Options(iterations=100000))
  params = Optim.minimizer(result)
  return params
end
