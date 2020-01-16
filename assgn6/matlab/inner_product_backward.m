function [param_grad, input_od] = inner_product_backward(output, input, layer, param)
% Y = WX + B
X = input.data;
W = param.w';
dLdY = output.diff;

dLdX = W' * dLdY;
dLdW = dLdY * X';
dLdB = sum(dLdY, 2);

input_od = dLdX;
param_grad.w = dLdW';
param_grad.b = dLdB';
end
