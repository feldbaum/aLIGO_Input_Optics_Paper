%Aproximate Requirements from T070236
f = logspace(1, 4, 1000);

% Rough Requriements
reqs = 2e-8/10^(3/2) * f.^(3/2);


% HSTS Length Noise
[lnoise,~,~]=seisSUS(f,'HSTS');
lnofilt=lnoise*2*2.99e8/(1064e-9*32.9462);

% PSL Freq Noise Reqs.
psl=11./(f);
psl(f>1e3)=psl(find(f>1e3,1,'first'));
psl(f<11)=psl(find(f<11,1,'last'));

% CARM Gain
carm = 1e8*10^4*1./f.^4;
carm = carm .* (f<100) + carm .* f.^2/100^2 .* (f >= 100);

% Requirements/Carm
reqCarm = reqs .* carm;


%% Plot
lnwdth = 2;
fntsz1 = 16;
fntsz2 = 18;

figure(1)
clf
set(gca, 'FontSize', fntsz1)
loglog(f, lnofilt,...
       'Linewidth', lnwdth,...
       'Color', 'b')
hold on
loglog(f, psl,...
       'Linewidth', lnwdth,...
       'Color', 'm')
loglog(f, reqs,...
       'Linewidth', lnwdth,...
       'Color', 'r')
loglog(f, reqCarm,...
       'Linewidth', lnwdth,...
       'Color', 'r',...
       'LineStyle', '--')
grid on
ylim([1e-8 1e0])
xlabel('Frequency (Hz)')
ylabel('Frequency Noise (Hz/rtHz)')
title('Frequency Noise Requirements Compared to Expected Noises',...
      'FontSize', fntsz2)
legend('Expected Input Mode Cleaner Length Noise',...
       'Expected Frequency Noise from the Pre Stabilized Laser',...
       'Frequency Noise Requirements at Interferometer Input',...
       'Frequency Noise Requirements after Common Arm Supression',...
       'Location', 'SouthEast')


%% Print
orient landscape
print -dpdf ../Freq_Noise_Reqs.pdf













