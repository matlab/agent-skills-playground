% Copyright 2026 The MathWorks, Inc.
%% MATLAB® AI Tutor Demo Kit: Array Indexing Assessment
% Complete the learner section, then run the script.

%% Setup
x = [2 4 6 8 10];

%% Learner section
% TODO: Select the second through fourth elements of x.
selected = x(2:4);

% TODO: Square each selected element using an element-wise operator.
squared = selected.^2;

%% Expected-output checks
assert(isequal(selected, [4 6 8]), "selected must contain elements 2 through 4 of x.");
assert(isequal(squared, [16 36 64]), "squared must square each selected element.");
assert(isequal(size(squared), [1 3]), "squared must remain a row vector.");

disp("Array indexing assessment passed.");
