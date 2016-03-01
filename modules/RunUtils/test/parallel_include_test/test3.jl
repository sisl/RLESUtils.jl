
const B = false

@show @__FILE__
@show myid()
@show B
open("out3.txt", "w") do f
  println(f, myid(), B)
end

