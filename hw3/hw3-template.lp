%*
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% KRR 2022, HOMEWORK ASSIGNMENT 3 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Name:             Piyush Bagad
Student number:   13677640

Name:             ...
Student number:   ...

*%

%*
INPUT REPRESENTATION:
- Represent the input of the problem (the map, the trucks, etc.)

[EXPLAIN YOUR CODE USING SHORT INLINE COMMENTS (SEE EXAMPLE BELOW)]
*%

% Represent the nodes and edges of the map using node/1 and edge/2.
node(1..13).
edge(1,2).
edge(2,3).
edge(3,4).
edge(4,5).
edge(5,6).
edge(6,7).
edge(7,8).
edge(8,9).
edge(9,10).
edge(10,11).
edge(11,12).
edge(12,13).
edge(7,13).
edge(5,8).
edge(5,9).
edge(3,9).
edge(3,10).
% ...

% Edges are undirected, so include their reverse
edge(X,Y) :- edge(Y,X).




%*
TIME STEPS:
- Represent the different time steps (up to some upper bound)

[EXPLAIN YOUR CODE USING SHORT INLINE COMMENTS]
*%

#const t=25. % This is an upper bound on the number of time steps needed




%*
ACTIONS:
- Represent the possible actions that each truck can take

[EXPLAIN YOUR CODE USING SHORT INLINE COMMENTS]
*%




%*
GENERATE A SEQUENCE OF ACTIONS:
- Generate a sequence of actions (for each truck)

[EXPLAIN YOUR CODE USING SHORT INLINE COMMENTS]
*%




%*
INITIAL STATE:
- Encode the initial state

[EXPLAIN YOUR CODE USING SHORT INLINE COMMENTS]
*%




%*
SUBSEQUENT STATES OF THE WORLD:
- Encode the subsequent states, based on the actions taken

Explanation (max 100 words):
[WRITE YOUR EXPLANATION HERE]
*%




%*
RESTRICTIONS ON THE ACTIONS:
- Restrict the actions taken by the trucks, based on the state of the world

Explanation (max 100 words):
[WRITE YOUR EXPLANATION HERE]
*%




%*
GOAL CONDITIONS:
- Constraints that express that the goal must be reached

Explanation (max 100 words):
[WRITE YOUR EXPLANATION HERE]
*%




%*
OPTIMIZATION:
- Express an optimization statement to find a solution within the smallest
  number of time steps

Explanation (max 100 words):
[WRITE YOUR EXPLANATION HERE]
*%




%*
OPTIONAL: ADDITIONAL RULES
- If you add anything to your program that doesn't fit in any of the other
  headings, put it here.

Explanation (max 100 words):
[WRITE YOUR EXPLANATION HERE]
*%




%*
THE END
*%
