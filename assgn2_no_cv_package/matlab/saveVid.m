function saveVid( path, mov )

writer = VideoWriter(path);
writer.FrameRate = 30;%

open(writer);
for i=1:length(mov)
    writeVideo(writer, mov(i).cdata);
end
close(writer);

end

