function [output] = relu_forward(input)
output.height = input.height;
output.width = input.width;
output.channel = input.channel;
output.batch_size = input.batch_size;

%%
data = input.data;
data(data<0) = 0;
output.data = data;
end
