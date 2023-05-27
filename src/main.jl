import Pkg
Pkg.activate(".")
Pkg.instantiate()
using Revise

using Flutes
using Dates
using YAML

data = YAML.load_file("constraints_A.yaml")
# input env vars
tuning= data["FLUTE_TUNING"]
scale = tones(data["FLUTE_SCALE"], tuning)
maxd = floats(data["FLUTE_MAX_DIAMETERS"])
maxp = floats(data["FLUTE_MAX_PADDING"])
rots = floats(data["FLUTE_HOLE_ROTATIONS"])
brk = data["FLUTE_BREAK"]
head_length = data["FLUTE_HEAD_LENGTH"]
tenon_length = data["FLUTE_TENON_LENGTH"]
trace = data["TRACE"]
destination_file=data["DEST"]

function rround(value)
  round(value; digits=3)
end

# minimum diameters = 1mm
mind = fill(1, length(maxd))
# calculate minimum padding between holes
minp = []
for h in 1:length(maxd)
  mp = 0
  if h == 1
    # first hole must be on body, not the headjoint
    mp = head_length+maxd[h]
  elseif h == brk+1
    # make room for the tenon/mortise at the break point
    mp = maxd[brk]+tenon_length+maxd[h]
  else
    # minimum hole spacing (sum of max diameters)
    mp = maxd[h-1]+maxd[h]
  end
  append!(minp, mp)
end

# find best fit
# all the magic happens here
println("Optimizing flute parameters: ", destination_file)
diameters, error = optimal(scale, mind, maxd, minp, maxp; trace=trace)
lengths = mapflute(scale, diameters)
# end magic

# display hole separations
with_origin = [0.0; lengths]
print("|")
for h in 1:length(lengths)
  print(" ∘ ", round(with_origin[h+1]-with_origin[h]; digits=1))
end
println(" |")

# break holes by foot/body
body_diameters = diameters[1:brk]
body_positions = lengths[1:brk]
body_rotations = rots[1:brk]

foot_diameters = diameters[brk+1:end]
foot_positions = lengths[brk+1:end-1]
foot_rotations = rots[brk+1:end]

# place body/foot joint
spare = max((foot_positions[1] - body_positions[end] - tenon_length)/2, 0)
nofoot = body_positions[end] + spare + tenon_length

flute_length = lengths[end]
body_length = nofoot - head_length
foot_length = flute_length - nofoot

# export parameters to opencad props
params = createscadparameters()
headset = "head.data"
setscadparameter!(params, headset, "HeadLength", head_length)
setscadparameter!(params, headset, "TenonLength", tenon_length)
bodyset = "body.data"
setscadparameter!(params, bodyset, "BodyLength", rround(body_length))
setscadparameter!(params, bodyset, "HoleDiameters", rround.(body_diameters))
setscadparameter!(params, bodyset, "HolePositions", map(bp->rround(bp-head_length), body_positions))
setscadparameter!(params, bodyset, "HoleRotations", body_rotations)

setscadparameter!(params, bodyset, "TenonLength", tenon_length)
setscadparameter!(params, bodyset, "MortiseLength", tenon_length)
footset = "foot.data"
setscadparameter!(params, footset, "FootLength", rround(foot_length))
setscadparameter!(params, footset, "HoleDiameters", rround.(foot_diameters))
setscadparameter!(params, footset, "HolePositions", map(fp->rround(fp-nofoot), foot_positions))
setscadparameter!(params, footset, "HoleRotations", foot_rotations)
setscadparameter!(params, footset, "MortiseLength", tenon_length)
extraset = "extra.data"
setscadparameter!(params, extraset, "CreationDate", now())
setscadparameter!(params, extraset, "Tuning", tuning)
setscadparameter!(params, extraset, "Scale", readvariable("FLUTE_SCALE"))
setscadparameter!(params, extraset, "Score", rround(error))
writescadparameters(params, destination_file)

