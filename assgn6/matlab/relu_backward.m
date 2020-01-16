function [input_od] = relu_backward(output, input, layer)
input_od = output.diff .* (input.data > 0);
end
