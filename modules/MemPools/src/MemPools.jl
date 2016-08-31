-

#memory pool, preallocate a collection of objects, checkout from pool and checkin when done
#dynamically allocate more until max_allocs
module MemPools

export MemPool, checkin, checkout

import Base: length, eltype

using DataStructures

immutable MaxSizeException <: Exception end

type MemPool{T}
  T::Type
  inventory::Stack{T}
  n_allocs::Int64
  max_allocs::Int64
end

#no dynamic expansions
function MemPool(T::Type, init_allocs::Int64)
  MemPool(T, init_allocs, init_allocs)
end

function MemPool(T::Type, init_allocs::Int64, max_allocs::Int64)
  rental = MemPool(T, Stack(T), 0, max_allocs)
  allocate!(rental, init_allocs)
  return rental
end

function checkout{T}(rental::MemPool{T})
  if isempty(rental.inventory)
    return allocate(rental)
  else
    return pop!(rental.inventory)
  end
end

function checkin{T}(rental::MemPool{T}, obj::T)
  push!(rental.inventory, obj)
end

length{T}(rental::MemPool{T}) = length(rental.inventory)
eltype{T}(rental::MemPool{T}) = T

function allocate!{T}(rental::MemPool{T}, N::Int64)
  for i = 1:N
    push!(rental.inventory, allocate(rental))
  end
end

function allocate{T}(rental::MemPool{T})
  if rental.n_allocs >= rental.max_allocs
    throw(MaxSizeException())
  end
  rental.n_allocs += 1
  return rental.T()
end

end #module
