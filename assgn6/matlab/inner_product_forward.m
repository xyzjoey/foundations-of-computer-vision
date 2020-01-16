function [output] = inner_product_forward(input, layer, param)

d = size(input.data, 1);
k = size(input.data, 2); % batch size
n = size(param.w, 2);

%%
X = input.data; % neuronPrev x batch
W = param.w'; % neuronCurr x neuronPrev
B = repmat(param.b', 1, k); % neuronCurr x batch
data = W*X + B;

%%
output.data = data;
output.height = input.height; %%% ?
output.width = input.width; %%% ?
output.channel = input.channel; %%% ?
output.batch_size = k;

end
