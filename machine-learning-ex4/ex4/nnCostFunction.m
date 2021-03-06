function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);
         
% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a 
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.
%
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%

% Feedforward
X = [ones(m, 1) X]; % 5000*401
z1 = X * Theta1'; % 5000*25
a1 = sigmoid(z1); % 5000*25
a1 = [ones(size(a1, 1), 1) a1]; % 5000*26
z2 = a1 * Theta2'; % 5000*10
a2 = sigmoid(z2);

% convert vector y to the form such  as [0,0,...,1,.0]'
y1 = zeros(size(y, 1), num_labels);
for i = 1:size(y, 1)
    y1(i, y(i)) = 1;
end
% compute cost function
J = sum(sum(-y1 .* log(a2) - (1 - y1) .* log(1 - a2))) / m;

% regualized cost function
J = J + lambda / (2 * m) * (sum(sum(Theta1(:,2:end) .^ 2)) + sum(sum(Theta2(:,2:end) .^ 2)));

% =========================================================================
% Backpropagation
for i = 1:m
    del_ta2 = a2(i, :)' - y1(i, :)'; % 10*1
    % del_ta1 = Theta2' * del_ta2 .* sigmoidGradient(z1(i, :))';
    % 上式是按照pdf指导的公式，但显然没有考虑偏置单元，最后一项是25*1的
    del_ta1 = Theta2' * del_ta2 .* [0;sigmoidGradient(z1(i, :))']; % 26*10 * 10*1 .* (26*1)
    del_ta1 = del_ta1(2:end);
    Theta1_grad = Theta1_grad + del_ta1 * X(i, :); % 25*1 * 1*401
    Theta2_grad = Theta2_grad + del_ta2 * a1(i, :); % 10*1 * 1*26
end
Theta1_grad = Theta1_grad / m;
Theta2_grad = Theta2_grad / m;

% regularize
temp1 = Theta1;
temp2 = Theta2;
temp1(:,1) = 0;
temp2(:,1) = 0;
Theta1_grad = Theta1_grad + lambda/m *temp1;              
Theta2_grad = Theta2_grad + lambda/m *temp2;

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];

end
