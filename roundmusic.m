% roundmusic.m
function [t, d, a, i] = roundmusic(t, d, a, i, start_idx, end_idx)
    if end_idx > length(t) || start_idx > length(t) || start_idx > end_idx
        disp('Invalid Index');
        return;
    end

    t_end = floor((t(end) + d(end) - 0.5) / 2) * 2 + 0.5;
    t_duration = t_end - t(start_idx);
    t = [t, t(start_idx:end_idx) + t_duration];
    d = [d, d(start_idx:end_idx)];
    a = [a, a(start_idx:end_idx)];
    i = [i, i(start_idx:end_idx)];
end


