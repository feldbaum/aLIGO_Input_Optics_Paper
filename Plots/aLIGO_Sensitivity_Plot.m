%% Import Data
% aLIGO design
temp = importdata('T0900288_ZERO_DET_high_P.txt');
aligo.f = temp(:,1);
aligo.h = temp(:,2);

% S6 measured
temp = importdata('S6_Data.txt');
s6.f = temp(:,1);
s6.h = sqrt(temp(:,2));


%% Plot
lnwdth = 2;
fntsz1 = 16;
fntsz2 = 20;

figure(1)
clf
set(gca, 'FontSize', fntsz1)
loglog(aligo.f, aligo.h,...
       'Linewidth', 2,...
       'Color', 'b');
hold on
loglog(s6.f, s6.h,...
       'Linewidth', 2,...
       'Color', 'r');
hold off
grid on
legend('aLIGO Design', 'S6 Measured')
xlabel('Frequency (Hz)')
ylabel('Strain (1/rtHz)')
title('Advanced LIGO Design Sensitivity', 'FontSize', fntsz2)
xlim([10 5e3])
ylim([1e-24 5e-20])


%% Print
orient landscape
print -dpdf ../aLIGO_Design_Sensitivity.pdf

