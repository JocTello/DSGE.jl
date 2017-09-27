"""
```
AltPolicy(rule, [forecast_init = identity], [color = :black], [linestyle = :solid])
```

Type defining an alternative policy rule.

### Fields

- `rule::Function`: A function that solves the model and replaces the
  baseline policy rule with the desired alternative rule. It is also
  responsible for augmenting the state-space system with the states in
  `m.endogenous_states_augmented`. This function must accept 1
  argument: an instance of a subtype of `AbstractModel`. It must return

- `forecast_init::Function`: A function that initializes forecasts
  under the alternative policy rule. Specifically, it accepts a model,
  an `nshocks` x `n_forecast_periods` matrix of shocks to be applied
  in the forecast, and a vector of initial states for the forecast. It
  must return a new matrix of shocks and a new initial state
  vector. If no adjustments to shocks or initial state vectors are
  necessary under the policy rule, this field may be omitted.

- `color::Colorant`: The color to plot this alternative policy in

- `linestyle::Symbol`: Line style for forecast plots under this
  alternative policy. See options from `Plots.jl`

"""
type AltPolicy
    key::Symbol
    eqcond::Function
    solve::Function
    setup::Function
    forecast_init::Function
    states::OrderedDict{Symbol, Int}
    equations::OrderedDict{Symbol, Int}
    color::Colorant
    linestyle::Symbol
end

function AltPolicy(key::Symbol, eqcond_fcn::Function, solve_fcn::Function;
                   forecast_init::Function = identity,
                   setup::Function = identity,
                   state_names::Vector{Symbol} = Symbol[],
                   equation_names::Vector{Symbol} = Symbol[],
                   color::Colorant = colorant"blue",
                   linestyle::Symbol = :solid)

    states    = OrderedDict{Symbol, Int}((var, i) for (i, var) in enumerate(state_names))
    equations = OrderedDict{Symbol, Int}((var, i) for (i, var) in enumerate(equation_names))

    AltPolicy(key, eqcond_fcn, solve_fcn, setup, forecast_init,
              states, equations, color, linestyle)
end

Base.string(a::AltPolicy) = string(a.key)

function eqcond_altpolicy(m::AbstractModel)
    altpol = alternative_policy(m)
    altpol.eqcond(m)
end

