# RunCases.jl #
Author: Ritchie Lee (ritchie.lee@sv.cmu.edu)

RunCases.jl is a Julia package to manage parameters and facilitate parameter studies.

## Example Usage ##


```
#!Julia

using RunCases

# generates all combinations (cartesian products)
cases = generate_cases(("x",[1,2,3]),("y",['a','b','c'])) 

# add a field to each case based on a function of parameters already in the case
add_field!(cases, "z", x -> x + 10, ["x"])

# Now, at your endpoint, you can iterate over the cases
for case in cases
  
  #and for each case, 
  #iterate over each parameter (key) and value pair
  for (k, v) in case
    println("key: $k, val: $v")
    #use the parameters
  end
  
  println("")
end
```