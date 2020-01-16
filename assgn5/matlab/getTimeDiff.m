function [deltaTimeStr, deltaTimeSec] = getTimeDiff(t1, t2)

deltaTimeStr = diff(duration({t1, t2}, 'Format', 'hh:mm:ss.SSS'));
deltaTimeSec = etime(datevec(datenum(t2)), datevec(datenum(t1)));

end
