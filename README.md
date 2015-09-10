# RunCases.jl #
Author: Ritchie Lee (ritchie.lee@sv.cmu.edu)

RunCases.jl is a Julia package to manage parameters and facilitate parameter studies.

## Example Usage ##


```
#!Julia

using RLESUtils.RunCases

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

# Obj2Dict.jl #
Author: Ritchie Lee (ritchie.lee@sv.cmu.edu)

Obj2Dict.jl is a Julia package that converts an object to/from a dict for storage in JSON format.  Type information is preserved.  Note that the module functions are not exported, so you must use explicit notation.

## Example Usage ##

```
#!Julia

using RLESUtils.Obj2Dict
using JSON

type MyType
  p::Int64
  q::String
end

x = MyType(0,"0")

# convert to dict
d = Obj2Dict.to_dict(x)

# save to json file
f = open("myfile.json", "w")
JSON.print(f, d)
close (f)

# load from file
f = open("myfile.json", "r")
d1 = JSON.parse(f)
close (f)

# recover the object
x1 = Obj2Dict.to_obj(d1)

```
