using QuickPOMDPs: QuickMDP
using POMDPs
using POMDPModelTools: Deterministic, Uniform
using POMDPPolicies: FunctionPolicy
using POMDPSimulators: RolloutSimulator

bj = QuickMDP(
    # gen = function (s, a, rng)        
    #     x, v = s
    #     vp = clamp(v + a*0.001 + cos(3*x)*-0.0025, -0.07, 0.07)
    #     xp = x + vp
    #     if xp > 0.5
    #         r = 100.0
    #     else
    #         r = -1.0
    #     end
    #     return (sp=(xp, vp), r=r)
    # end,
    actions = [:hit,:stay],
    # states = 
    transition = function (s, a)
        if s == -1
            return Deterministic(s)

        elseif s > 21
            return Deterministic(-1)
        elseif a == :hit
            return Uniform(s .+ [1,2,3,4,5,6,7,8,9,10])
        elseif a == :stay
            return Deterministic(s)
        end
    end,

    reward = function (s, a)
        if s > 21 
            return -1.0
        elseif s == 21
            return 1.0
        elseif s < 21
            return 0.0
        end
    end,
    

    initialstate = Uniform([1,2,3,4,5,6,7,8,9,10]),
    discount = 1.0,
    isterminal = s->s == -1
)

# evaluate with a always wait policy
policy = FunctionPolicy(a->rand(POMDPs.actions(bj)))
sim = RolloutSimulator(max_steps=100)
@show [POMDPs.simulate(sim, bj, policy) for _ in 1:100]