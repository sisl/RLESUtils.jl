module script_test1jl

const B = true

function main()
  @show @__FILE__
  @show myid()
  @show B
  open("out1.txt", "w") do f
    println(f, myid(), B)
  end
end

nothing
end
