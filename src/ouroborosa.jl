## The avalance Planner
## ====================

u# Tick Tock
3. search_algorithm is now modified, depth is 1
7. search algorithm even newer, depth is now 2
def tick_tock(search_algorithm, policy, policy_fitness, search_fitness, depth):
	MAX_DEPTH = 2
	if depth < MAX_DEPTH:
		while (True):
			policy = search_algorithm(policy, policy_fitness) #tick
			make search_fitness close over depth, policy
			search_algorithm = search_algorithm(search_algorithm, search_fitness) #tock
	else:x`
		policy = search_algorithm(policy,policy_fitness)

	return (search_algorithm, policy, policy_fitness(policy))


# Find local optima by climbing to best neighbours
1. looking for a new search algorithm with original random serach
def stochastic_ascent(initial_solution, fitness_algorithm):
	neighbours = find_neighbours(initial_solution)
	for (neighbour in neighbours):


	current = max(neighbour)
	return current

4. looking for a new optimal policy with modified search algorithm
5. looking for a new new search algorith with new search algorithm
def modified_search_algorithm : ...

q# Run with this policy in grid world
def policy_fitness(policy):
	agent = Agent(policy)
	GridWorld.addAgent(agent)
	reward = agent.run()
	return reward

2. evaluating the fitness of a randomly selected search algorithm
6. evaluating fitness of new new search algorithm
def search_fitness(search_algorithm):
	optimal_policy = tick_tock(search_algorithm, policy, policy_fitness, search_fitness, depth + 1)
	return policy_fitness(optimal_policy)

criteria are:
I want the search algorithm to find better solutions

# This assumes that the algorithm which should be effective in finding a good policy
# should also be effective in finding a good search algorithm.  Is this justified?

When I come to evaluate the quality of a new search algorithm.
I want to know
- How, if I use this new algorithm, will the resulting policy I can find be better or worse
- I.e. if under a new search algorithm, I can find a better solution, then I should adopt this search algorithm.
However this is not sufficient.  Because I may find a new search algorithm, which helps me find a better

world = GridWorld()
policy = Program()
best_policy = tick_tock(stochastic_ascent, policy, policy_fitness, search_fitness, 0)