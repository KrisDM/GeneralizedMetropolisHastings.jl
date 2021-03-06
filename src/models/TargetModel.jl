immutable TargetModel{P<:AbstractParameter,D<:AbstractData,N<:AbstractNoiseModel} <: AbstractModel

    #Generic model specs
    name::AbstractString
    parameters::Vector

    measurements::D
    noisemodel::N

    target::Function #target function
    args::Tuple #additional arguments for the target function

    ###temp location to store model data
    inplacetarget::Bool
    evalresults::Array

    TargetModel(name::AbstractString,parameters::Vector{P},measurements::D,noisemodel::N,
                inplacetarget::Bool,evalresults::Array,target::Function,args...) = new(name,parameters,measurements,noisemodel,target,args,inplacetarget,evalresults)
end

function TargetModel(name::AbstractString,parameters::Vector,measurements::AbstractData,noisemodel::AbstractNoiseModel,inplacetarget::Bool,target::Function,args...)
    P = eltype(parameters)
    D = typeof(measurements)
    N = typeof(noisemodel)
    TargetModel{P,D,N}(name,parameters,measurements,noisemodel,inplacetarget,similar(datavalues(measurements)),target,args...)
end

###Factory functions
function _model(::Type{Val{:target!}},parameters::Vector,measurements::AbstractData,noisemodel::AbstractNoiseModel,target::Function,args...;name="TARGET!")
    TargetModel(name,parameters,measurements,noisemodel,true,target,args...)
end

function _model(::Type{Val{:target}},parameters::Vector,measurements::AbstractData,noisemodel::AbstractNoiseModel,target::Function,args...;name="TARGET")
    TargetModel(name,parameters,measurements,noisemodel,false,target,args...)
end

@inline _evaluate(::Type{Val{true}},m::TargetModel,vals::AbstractVector) = m.target(m.evalresults,dataindex(m),m.args...,vals)
@inline _evaluate(::Type{Val{false}},m::TargetModel,vals::AbstractVector) = copy!(m.evalresults,m.target(dataindex(m),m.args...,vals))

###Evaluate the model for the given parameter values
evaluate!(m::TargetModel,vals::AbstractVector) = (_evaluate(Val{m.inplacetarget},m,vals) ; m.evalresults)

###Utility functions used in generic implementations in AbstractModel
@inline dataindex(m::TargetModel) = dataindex(m.measurements)
@inline measurements(m::TargetModel) = datavalues(m.measurements)
@inline noisemodel(m::TargetModel) = m.noisemodel

###Base.show function
function show(io::IO,m::TargetModel)
    println(io,"TargetModel ",m.name)
    print(io,"parameters: ") ; show(io,m.parameters)
    print(io,"measurements: ") ; show(io,m.measurements)
    print(io,"noisemodel: ") ; show(io,m.noisemodel)
    println(io,"target: ",m.target)
    if ~isempty(m.args)
        println(io,"Additional target function arguments: ")
        show(io,m.args)
        println(io)
    end
    nothing
end
