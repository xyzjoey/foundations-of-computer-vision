function [output] = conv_layer_forward(input, layer, param)
% Conv layer forward
% input: struct with input data
% layer: convolution layer struct
% param: weights for the convolution layer

% output: 

h_in = input.height;
w_in = input.width;
c = input.channel;
batch_size = input.batch_size;
k = layer.k;
pad = layer.pad;
stride = layer.stride;
num = layer.num;
% resolve output shape
h_out = (h_in + 2*pad - k) / stride + 1;
w_out = (w_in + 2*pad - k) / stride + 1;

assert(h_out == floor(h_out), 'h_out is not integer')
assert(w_out == floor(w_out), 'w_out is not integer')
input_n.height = h_in;
input_n.width = w_in;
input_n.channel = c;

%% Fill in the code
% Iterate over the each image in the batch, compute response,
% Fill in the output datastructure with data, and the shape. 

data = zeros(h_out*w_out*num, batch_size);

for i = 1:batch_size
    img3D = reshape(input.data(:,i), h_in, w_in, c); % 28 x 28 x c
    filterResponse3D = filterAll(img3D, param, h_out, w_out, c, k, pad, stride, num); % h_out x w_out x num
    data(:, i) = reshape(filterResponse3D, [], 1); % (h_out * w_out * c * num) x 1
end

%%
output.data = data;
output.height = h_out;
output.width = w_out;
output.channel = num;
output.batch_size = batch_size;

end

%%
function filterResponse3D = filterAll(img, param, h_out, w_out, c, k, pad, stride, filterNum)
filterResponse3D = zeros(h_out, w_out, filterNum);
for n = 1:filterNum
    w = reshape(param.w(:,n), k, k, c); % k x k x c
    b = param.b(n);
    filterResponse3D(:,:,n) = filter(img, w, b, pad, stride);
end
end

function filterResponse = filter(img, w, b, pad, stride)
imgPad = padarray(img, [pad pad]);
filterResponse = convn(imgPad, w, 'valid');
filterResponse = filterResponse + b;
filterResponse = filterResponse(1:stride:end,1:stride:end,:);
end
