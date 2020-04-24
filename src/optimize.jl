import Pkg
Pkg.activate(".")

using Flutes
using Dates

function floats(var)
  return mapvariable(x->parse(Float64, x), var)
end

function tones(var, A)
  return mapvariable(v->tone(v; A=A), var)
end

# input env vars
scale = tones("FLUTE_SCALE", 442.0)
mind = floats("FLUTE_MIN_DIAMETERS")
maxd = floats("FLUTE_MAX_DIAMETERS")
minp = floats("FLUTE_MIN_PADDING")
maxp = floats("FLUTE_MAX_PADDING")
brk = parse(Int, readvariable("FLUTE_BREAK"))

flute = createflute(scale[end])
for h in 1:length(scale)-1
  # constrain hole diameters & positions
  addtonehole!(flute, scale[h]; 𝑑₋=mind[h], 𝑑₊=maxd[h], 𝑝₋=minp[h], 𝑝₊=maxp[h])
end
# find best fit
# all the magic happens here
diameters = optimal(flute)
# end magic

# break holes by foot/body
foot_diameters = []
foot_positions = []
body_diameters = []
body_positions = []
𝛥𝜆ᵥ = 0.0 # closed-hole correction
𝒇 = map(ℎ->ℎ.𝑓, flute.holes); push!(𝒇, flute.𝑓)
for h in 1:length(diameters)
  𝑓ₕ = flute.holes[h].𝑓
  𝑑ₕ = diameters[h]
  𝑓ₜ = 𝒇[h+1]
  ℓₕ = toneholelength(𝑓ₕ; 𝑓ₜ=𝑓ₜ, 𝑑=𝑑ₕ, 𝛥𝜆ᵥ=𝛥𝜆ᵥ)
  if h <= brk
    push!(body_diameters, 𝑑ₕ)
    push!(body_positions, ℓₕ)
  else
    push!(foot_diameters, 𝑑ₕ)
    push!(foot_positions, ℓₕ)
  end
  global 𝛥𝜆ᵥ += closedholecorrection(𝑓ₕ; 𝑓ₜ=𝑓ₜ, 𝑑=𝑑ₕ, 𝛥𝜆ᵥ=𝛥𝜆ᵥ)
end
flute_length = flutelength(flute.𝑓; 𝛥𝜆ᵥ=𝛥𝜆ᵥ)

# TODO: externalize constants
tenon_length = 26
head_length = 145

# place body/foot joint
spare = max((foot_positions[1] - body_positions[end] - tenon_length)/2, 0)
nofoot = body_positions[end] + spare + tenon_length
body_length = round(nofoot - head_length; digits=3)
foot_length = round(flute_length - nofoot; digits=3)

# export parameters to opencad props
params = createscadparameters()
headset = "head.data"
setscadparameter!(params, headset, "HeadLength", head_length)
setscadparameter!(params, headset, "TenonLength", tenon_length)
bodyset = "body.data"
setscadparameter!(params, bodyset, "BodyLength", body_length)
setscadparameter!(params, bodyset, "HoleDiameters", map(bd->round(bd; digits=3), body_diameters))
setscadparameter!(params, bodyset, "HolePositions", map(bp->round(bp-head_length; digits=3), body_positions))
setscadparameter!(params, bodyset, "TenonLength", tenon_length)
setscadparameter!(params, bodyset, "MortiseLength", tenon_length)
footset = "foot.data"
setscadparameter!(params, footset, "FootLength", foot_length)
setscadparameter!(params, footset, "HoleDiameters", map(fd->round(fd, digits=3), foot_diameters))
setscadparameter!(params, footset, "HolePositions", map(fp->round(fp-nofoot; digits=3), foot_positions))
setscadparameter!(params, footset, "MortiseLength", tenon_length)
extraset = "extra.data"
setscadparameter!(params, extraset, "CreationDate", now())
writescadparameters(params, ARGS[1])

