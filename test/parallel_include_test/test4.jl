module script_test4jl

const B = false

function main()
  @show @__FILE__
  @show myid()
  @show B
  open("out4.txt", "w") do f
    println(f, myid(), B)
  end
end

nothing
end #module
