%merge.c
function [t, d, a, i] = merge(t_1, t_2, d_1, d_2, a_1, a_2, i_1, i_2)
  t = [];
  d = [];
  a = [];
  i = [];
  x = 1;
  y = 1;
  
  while x <= length(t_1) && y <= length(t_2)
    if t_1(x) <= t_2(y)
      t = [t, t_1(x)];
      d = [d, d_1(x)];
      a = [a, a_1(x)];
      i = [i, i_1(x)];
      x = x + 1;
    else
      t = [t, t_2(y)];
      d = [d, d_2(y)];
      a = [a, a_2(y)];
      i = [i, i_2(y)];
      y = y + 1;
    end
  end
  
  if x > length(t_1)
    t = [t, t_2(y:end)];
    d = [d, d_2(y:end)];
    a = [a, a_2(y:end)];
    i = [i, i_2(y:end)];
  else
    t = [t, t_1(x:end)];
    d = [d, d_1(x:end)];
    a = [a, a_1(x:end)];
    i = [i, i_1(x:end)];
  end
end
