const B = true

@show @__FILE__
@show myid()
@show B
open("out2.txt", "w") do f
  println(f, myid(), B)
end
