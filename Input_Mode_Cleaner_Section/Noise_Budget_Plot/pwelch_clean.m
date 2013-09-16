% This function takes in the outputs of Pwelch (pxx,f0) and a specified
% maximum density of points per decade (dens).  For sections in which the
% density of points is higher than the specified density it averages the
% points in that section together and defines the frequency point as the
% midpoint.  
%
% Some notes: 
% 1. This function effectively switches from linear to log spacing, binning
% the points when necessary.
% 2. Since this function simply averages the points together, the data must
% be linearly spaced to begin with or the power per bin will not be
% conserved.  This means that, for instance, you cannot pass this 
% function's outputs back to itself.  
% 3. Similary, it is important that the function be passed the PSD directly
% from pwelch (not an asd) otherwise the averaging will not conserve power.
% 
% Edits:
% Created on 11/06/2012 by Chris M.
% 
% Usage: [pxxout, f0out] = pwelch_clean( pxx, f0, dens)

function [pxxout, f0out] = pwelch_clean(pxx,f0,dens)

arg.pxx = pxx;
arg.f0 = f0;
prm.dens = dens;

if arg.f0(1) == 0
    arg.f0 = arg.f0(2:(length(arg.f0)));
    arg.pxx = arg.pxx(2:(length(arg.pxx)));
end


%% Windows
%Per Decade

temp.wind.mid = logspace(0,1,prm.dens);
temp.lnt = length(temp.wind.mid);
temp.bot = 1/2+temp.wind.mid(1)/(2*temp.wind.mid(2));
temp.top = 1/2+temp.wind.mid(2)/(2*temp.wind.mid(1));

temp.wind.bot = temp.wind.mid*temp.bot;
temp.wind.top = temp.wind.mid*temp.top;

%Assemble
temp.nums = floor(log10(min(arg.f0))):1:ceil(log10(max(arg.f0)));
intl.wind.bot = [];
intl.wind.top = [];
intl.wind.mid = [];
for jj = temp.nums
    intl.wind.bot = horzcat(intl.wind.bot,...
        temp.wind.bot(1:(temp.lnt-1))*10^jj);
    intl.wind.top = horzcat(intl.wind.top,...
        temp.wind.top(1:(temp.lnt-1))*10^jj);
    intl.wind.mid = horzcat(intl.wind.mid,...
        temp.wind.mid(1:(temp.lnt-1))*10^jj);
end


%% Binning
temp.lnt = length(intl.wind.mid);
loop.cnt = 0;
for jj = 1:temp.lnt
    loop.mask = intl.wind.bot(jj)<arg.f0 &...
        arg.f0<intl.wind.top(jj);
    loop.num = sum(loop.mask);
    if loop.num == 0
        continue
    elseif loop.num == 1
        loop.cnt = loop.cnt+1;
        main.f0(loop.cnt) = arg.f0(loop.mask);
        main.pxx(loop.cnt) = arg.pxx(loop.mask);
    else
        loop.cnt = loop.cnt+1;
        main.f0(loop.cnt) = intl.wind.mid(jj);
        main.pxx(loop.cnt) = mean(arg.pxx(loop.mask));
    end
end
    
pxxout = main.pxx;
f0out = main.f0;



























