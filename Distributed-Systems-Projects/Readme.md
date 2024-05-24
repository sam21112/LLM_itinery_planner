# Projects for Coursework- COP5615-Distributed Operating System Principles

Projects completed Successfully by Yash Goel(UFID-51939756)
 
## Projects Description

### Project 1 Distributed Bit Coin Miner on Erlang

Bitcoins are the most popular crypto-currency in common use. At their hart, bitcoins use the hardness of cryptographic hashing to ensure a limited “supply” of coins. In particular, the key component in a bitcoin is an input that, when “hashed” produces an output smaller than a target value. In practice, the comparison values have leading 0’s, thus the bitcoin is required to have a given number of leading 0’s. The hash used is SHA-256. For the coins we find, we check our answer with the calculator to ensure correctness. The goal of this first project is to use Erlang and the actor model to build a good solution to this problem that runs well on multi-core machines.

###  Project 2 Gossip Simulator
Gossip type algorithms can be used both for group communication and for aggregate computation. The goal of this project is to determine the convergence of such algorithms through a simulator based on actors written in Erlang. Since actors in Erlang are fully asynchronous, the particular type of Gossip implemented is the so called Asynchronous Gossip. Gossip Algorithm for information propagation<br>

The Gossip algorithm:

• <b>Starting</b>: A participant(actor) it told/sent a roumor(fact) by the main process<br>
• <b>Step</b>: Each actor selects a random neighboor and tells it the roumor<br>
• <b>Termination</b>: Each actor keeps track of rumors and how many times it has heard the rumor. It stops transmitting once it has heard the rumor 10 times (10 is arbitrary, you can select other values).<br>

Push-Sum algorithm

• <b>State</b>: Each actor Ai maintains two quantities: s and w. Initially, s = xi = i (that is actor number i has value i, play with other distribution if you so desire) and w = 1<br>
• <b>Starting</b>: Ask one of the actors to start from the main process.<br>
• <b>Receive</b>: Messages sent and received are pairs of the form (s, w). Upon receive, an actor should add received pair to its own corresponding values. Upon receive, each actor selects a random neighbour and sends it a message.<br>
• <b>Send</b>: When sending a message to another actor, half of s and w is kept by the sending actor and half is placed in the message. <br>
• <b>Sum estimate</b>: At any given moment of time, the sum estimate is s/w where s and w are the current values of an actor.<br>
• <b>Termination</b>: If an actors ratio s/w did not change more than 10^-10 in 3 consecutive rounds the actor terminates. <br>

The actual network topology plays a critical role in the dissemination speed of Gossip protocols. As part of this project you have to experiment with various topologies. The topology determines who is considered a neighboor in the above algorithms.

• <b>Full Network</b> Every actor is a neighboor of all other actors. That is, every actor can talk directly to any other actor.<br>
• <b>2D Grid</b> Actors form a 2D grid. The actors can only talk to the grid neigboors.<br>
• <b>Line: Actors</b> are arranged in a line. Each actor has only 2 neighboors.<br>
• <b>Imperfect 2D Grid</b> Grid arrangement but one random other neighboor is selected from the list of all actors.<br>

