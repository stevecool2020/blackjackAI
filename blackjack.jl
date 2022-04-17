using QuickPOMDPs: QuickMDP
using POMDPs
using POMDPModelTools: Deterministic, Uniform
using POMDPPolicies: FunctionPolicy
using POMDPSimulators: RolloutSimulator



bj = QuickMDP(
 
    # state[1] = players hand 
    # state[2] = dealer showing 
    # TODO: state[3] = usable ace? 
    actions = [:hit,:stay], # could add double down or surrender
    transition = function (s, a)
        
        if s[1] == -1 # turn is already over 
            splayer = Deterministic(-1)

        elseif s[1] >= 21 # player has gone over 21, turn ends
            splayer =  Deterministic(-1)
             
        elseif a == :hit # hitting randomly selects a card
            splayer =  Uniform(s[1] .+ [1,2,3,4,5,6,7,8,9,10])
        elseif a == :stay
            splayer =  Deterministic(-1) # staying ends turn 
        end
        sout = (splayer, Deterministic(s[2]))
        return sout
    end,

    reward = function (s, a)
        if s[1] > 21 # player has gone over and loses
            return -1.0
        elseif s[1] == 21 # player has hit 21 and won
            return 1.0
        elseif s[1] < 21 # game is still going 
            return 0.0
        end
    end,
    observation = function (s, a, sp)
        return s # not a pomdp, the exact state is known
    end,

    # This doesn't work 
    # initialstate = (Uniform([1,2,3,4,5,6,7,8,9,10]), Deterministic(0)), # intial draw from the deck 
    initialstate = Deterministic((0, 0)), # intial draw from the deck 
    discount = 1.0, # not a discounted game 
    isterminal = function (s)
        if s[1] == -1 # -1 is our terminal state
            return true
        else 
            return false
        end
    end
)

policy = FunctionPolicy(a->POMDPs.actions(bj)[1]) # always hit policy 
sim = RolloutSimulator(max_steps=100)
@show reward_ = [POMDPs.simulate(sim, bj, policy) for _ in 1:100]
@show mean(reward_)