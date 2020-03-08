export FluteConstraint, ToneHoleConstraint
export optimal, createflute, addtonehole
using Optim

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

function addtonehole!(flute::FluteConstraint, 𝑓; 𝑑₋=2.0, 𝑑₊=9.0, 𝑝₋=18.0, 𝑝₊=24.0)
  push!(flute.holes, ToneHoleConstraint(𝑓, 𝑑₋, 𝑑₊, 𝑝₋, 𝑝₊))
end

function createflute(𝑓)
  return FluteConstraint(𝑓, [])
end

function createflute()
  f = createflute(note("D4"))
  addtonehole!(f, note("E4"); 𝑝₊=Inf, 𝑑₊=7.0)
  addtonehole!(f, note("F4"); 𝑝₊=20.0)
  addtonehole!(f, note("G4"))
  addtonehole!(f, note("A4"); 𝑝₊=30.0)
  addtonehole!(f, note("B♭4"); 𝑝₊=Inf)
  addtonehole!(f, note("C5"))
  addtonehole!(f, note("D5"))
  return f
end

# error function factory (constraints)
function mkerrfn(flute::FluteConstraint)
  # return error function
  ℓₜ= flutelength(flute.𝑓)
  𝑯 = 1:length(flute.holes)
  function errfn(𝒅)
    ϵ = 0.0
    ℓₓ = ℓₜ # length of last hole, or flute
    for h in 𝑯
      # for each hole calculate error
      𝒉 = flute.holes[h]
      𝑑ₕ = 𝒅[h]
      ℓₕ = toneholelength(𝒉.𝑓; 𝑑=𝑑ₕ)
      # target ideal placement
      ℓmax = ℓₓ - 𝒉.𝑝₋
      ℓmin = ℓₓ - 𝒉.𝑝₊
      λℓₐ = abs(ℓmax - ℓₕ)
      λℓᵦ = max(0, ℓmin - ℓₕ) + max(0, ℓₕ - ℓmax)
      ϵ += λℓₐ + λℓᵦ^2
      # next loop use this hole as last hole
      ℓₓ = ℓₕ
    end
    return ϵ
  end
  return errfn
end

function minbox(flute::FluteConstraint)
  𝒅₋ = map(𝒉->𝒉.𝑑₋, flute.holes)
  𝒅₊ = map(𝒉->𝒉.𝑑₊, flute.holes)
  𝒅₀ = map(𝑑->𝑑-rand(), 𝒅₊)
  return (𝒅₋, 𝒅₊, 𝒅₀)
end

function optimal(flute)
  # minimize error function
  errfn = mkerrfn(flute)
  # box-constrained, initial parameters
  minp, maxp, initp = minbox(flute)
  result = optimize(errfn, minp, maxp, initp, Fminbox(BFGS()))
  # check for convergence
  if !Optim.converged(result)
    println("warning: unable to converge on a result")
  end
  println(result)
  params = Optim.minimizer(result)
  x = flutelength(flute.𝑓)
  for h in 1:length(flute.holes)
    hole = flute.holes[h]
    print("𝑓ₕ: ", round(hole.𝑓; digits=2))
    print(" 𝑑ₕ: ", round(params[h]; digits=2))
    l = toneholelength(hole.𝑓, 𝑑=params[h])
    print(" 𝑝ₕ: ", round(x-l; digits=2))
    println(" ℓₕ: ", round(l; digits=2))
    x = l
  end
  # return minimizer
  return map(𝑑->round(𝑑; digits=2), params)
end
