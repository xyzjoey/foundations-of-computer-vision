function [output] = pooling_layer_forward(input, layer)

h_in = input.height;
w_in = input.width;
c = input.channel;
batch_size = input.batch_size;
k = layer.k;
pad = layer.pad;
stride = layer.stride;

h_out = (h_in + 2*pad - k) / stride + 1;
w_out = (w_in + 2*pad - k) / stride + 1;


output.height = h_out;
output.width = w_out;
output.channel = c;
output.batch_size = batch_size;

%%
data = zeros([h_out*w_out*c, batch_size]);
for i = 1:batch_size
    img1D = input.data(:,i);
    img3D = reshape(img1D, h_in, w_in, c);
    img3DPooled = pool(img3D, h_out, w_out, k, pad, stride); % h_out x w_out x c
    data(:,i) = reshape(img3DPooled, [], 1);
end

output.data = data;

end

%%
function pooled = pool(img3D, h_out, w_out, k, pad, stride)
[h, w, c] = size(img3D);
imgPad = padarray(img3D, [pad pad]);
pooled = zeros(h_out, w_out, c);

x = 1;
y = 1;
for i = 1:stride:h-(k-1)
    for j = 1:stride:w-(k-1)
        pooled(y,x,:) = max(imgPad(i:i+k-1,j:j+k-1,:), [], [1 2]);
        x = x + 1;
    end
    x = 1;
    y = y + 1;
end
end