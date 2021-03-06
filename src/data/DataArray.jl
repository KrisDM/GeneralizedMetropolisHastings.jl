immutable DataArray{T<:Number,D<:Number,A<:AbstractArray} <: AbstractData
    index::Vector
    values::A
    DataArray(i::AbstractVector{T},d::AbstractArray{D}) = new(collect(i),d)
end

function _data(::Type{Val{:array}},i::AbstractVector,d::AbstractArray)
    @assert length(i) == size(d,1)
    DataArray{eltype(i),eltype(d),typeof(d)}(i,d)
end

numvalues(d::DataArray) = size(d.values,1)
numvars(d::DataArray) = size(d.values,2)
eltype(d::DataArray) = eltype(d.values)
generate!(d::DataArray) = d.values
dataindex(d::DataArray) = d.index
datavalues(d::DataArray) = d.values
datatypename(d::DataArray) = "DataArray"
