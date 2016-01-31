module script_test3jl

const B = false

function main()
  @show @__FILE__
  @show myid()
  @show B
  open("out3.txt", "w") do f
    println(f, myid(), B)
  end
end

nothing
end #module
