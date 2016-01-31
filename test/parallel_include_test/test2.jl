module script_test2jl

const B = true

function main()
  @show @__FILE__
  @show myid()
  @show B
  open("out2.txt", "w") do f
    println(f, myid(), B)
  end
end

nothing
end #module
