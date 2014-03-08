clear all


data = importdata('mcpole589pdfss.dat');
lnt = length(data);
data = data(1:(lnt-1),:);

freq = data(:,1);
mag = data(:,2);
phs = data(:,3);




%% Parameter Variation
%Frequency Range
fit.rng = [2e3 1e5];

%Prep Data
fit.bool = fit.rng(1)<=freq & freq<=fit.rng(2);
fit.freq = freq(fit.bool);
fit.mag = mag(fit.bool);
fit.phs = phs(fit.bool);
fit.data = 10.^(fit.mag./20).*exp(1i.*pi./180.*fit.phs);

%Parameter Ranges
fit.ofs = -8.0:0.05:-6.0; %Data offset in dB
fit.pole = 8.7e3:0.50:8.9e3;  %Cavity Pole frequcnce in Hz


%
fit.mat = zeros([length(fit.ofs) length(fit.pole)]);

lnt1 = length(fit.ofs);
lnt2 = length(fit.pole);
for j=1:lnt1
    loop.ofs = fit.ofs(j);
    loop.mag = 10.^((fit.mag-loop.ofs)/20);
    loop.phs = pi./180*fit.phs;
    loop.data = loop.mag.*exp(1i.*loop.phs);
    for k=1:lnt2
        loop.pole = fit.pole(k);
        loop.tf = zpk([],-2*pi*loop.pole,2*pi*loop.pole);
        loop.tf = squeeze(freqresp(loop.tf,2*pi*fit.freq));
        fit.mat(j,k) = sum(abs(loop.tf - loop.data).^2);
    end
    j/lnt1
end
clear loop

% 
fit.min = min(min(fit.mat));

figure(2)
clf
imagesc(fit.pole*1e-3,fit.ofs,fit.mat,[fit.min 3*fit.min])
colorbar
ylabel('Offset (dB)')
xlabel('Cavity Pole (kHz)')


        
%% Expected
%Minimum
fit2.ind = zeros(1,2);
[tempd, tempi] = min(fit.mat);
[fit2.res, fit2.ind(2)] = min(tempd);
fit2.ind(1)=tempi(fit2.ind(2));
clear temp*

fit2.omega0 = fit.pole(fit2.ind(2));
fit2.tf = zpk([],-2*pi*[fit2.omega0],(2*pi*fit2.omega0));
fit2.freq = logspace(2,5,1e3);

fit2.resp = squeeze(freqresp(fit2.tf,2*pi*fit2.freq));
fit2.mag = 20*log10(abs(fit2.resp));
fit2.phs = 180/pi*angle(fit2.resp);

fnt1 = 14;
fnt2 = 16;
lnwt = 2;
mrkr = 8;

clrs = [204 102 0; ...
        0   0   153]/255;

figure(1)
clf
subplot(2,1,1)
set(gca, 'FontSize', fnt1)
semilogx(freq,mag-fit.ofs(fit2.ind(1)), 'x', ...
    'LineWidth', lnwt, 'Color', clrs(1,:), 'MarkerSize', mrkr)
hold on
semilogx(fit2.freq, fit2.mag, ...
    'LineWidth', lnwt, 'Color', clrs(2,:))
hold off
ylabel('Magnitude (dB)', 'FontSize', fnt1)
title('Input Mode Cleaner Cavity Pole', 'FontSize', fnt2)
xlim([min(freq) max(freq)])
set(gca, 'PlotBoxAspectRatio', [3 1 1])
grid on

subplot(2,1,2)
set(gca, 'FontSize', fnt1)
semilogx(freq, phs, 'x', ...
    'LineWidth', lnwt, 'Color', clrs(1,:), 'MarkerSize', mrkr)
hold on
semilogx(fit2.freq, fit2.phs, ...
    'LineWidth', lnwt, 'Color', clrs(2,:))
hold off
ylabel('Phase (deg)', 'FontSize', fnt1)
xlabel('Frequency (Hz)', 'FontSize', fnt1)
xlim([min(freq) max(freq)])
set(gca, 'PlotBoxAspectRatio', [3 1 1])
grid on

orient landscape
print -dpdf ../Cavity_Pole.pdf

%% Losses

los.c = 2.998e8;
los.l = 32.9462;
los.t1 = sqrt(6150e-6*0.9);
los.t3 = sqrt(6130e-6*0.9);
los.t2 = sqrt(3.5e-6);

los.r1 = sqrt(1-los.t1^2);
los.r3 = sqrt(1-los.t3^2);
los.r2 = sqrt(1-los.t2^2);

%Expected Pole
temp = 1/(2*pi)*(1-los.r1*los.r2*los.r3)/(los.r1*los.r2*los.r3)*los.c/los.l;


%Loss Fitting
los.loss = 0:1e-6:200e-6;
los.res = zeros(size(los.loss));
los.omega = los.res;

for j=1:length(los.loss)
    loop.loss = los.loss(j);
    
    loop.r1 = sqrt(los.r1^2-loop.loss);
    loop.r2 = sqrt(los.r2^2-loop.loss);
    loop.r3 = sqrt(los.r3^2-loop.loss);
    
    los.omega(j) = 1/(2*pi)*(1-loop.r1*loop.r2*loop.r3)/...
        (loop.r1*loop.r2*loop.r3)*los.c/los.l;
    
    los.res(j) = abs(los.omega(j) - fit2.omega0)^2;
end

figure(3)
clf
plot(los.loss,los.omega)
xlabel('Losses')
ylabel('Residuals')
































































