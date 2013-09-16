%% Load the data
clear all

% Load the Noise Data
load IMC_NB_Internal_Data_Feb_05_2013.mat

% Load the ArbLoop Transfer Functions
load Frequency_Noise_Tfs.mat;

%% Radiation Pressure 
nsout.rp.name = 'Radiation Pressure';
nsout.rp.f = intl.rp.fdom.freq;

% Interpolate ArbLoop TF
tf = interp1( ftf.f, ftf.rp, nsout.rp.f);

% Multiply by TF
nsout.rp.y = abs( tf) .* intl.rp.fdom.data;

%% Seismic
% The seismic noise is already propogated to length noise at the cavity so
% it needs to be injected at that point.
nsout.seis.name = 'Seismic Noise';
nsout.seis.f = intl.seis.freq;

% Interpolate ArbLoop TF
tf = interp1( ftf.f, ftf.length, nsout.seis.f);

% Multiply by TF
nsout.seis.y = abs( tf) .* intl.seis.data;

%% BOSEM
nsout.sens.name = 'Damping Sensor Noise';
nsout.sens.f = intl.sens.freq;

% Interpolate ArbLoop TF
tf = interp1( ftf.f, ftf.sens, nsout.sens.f);

% Multiply by TF
nsout.sens.y = abs( tf) .* intl.sens.data;

%% Servo Dark Noise
%===== Import and Process the Data =====
% IMC_F is in column 3 and IMC_X is in column 2
data = importdata( '../Noise_Budget_Plot/coupServoDark.txt');

% Convert IMC_X to meters and de whiten
intl.imcxfilt = squeeze( freqresp(...
    zpk( -2*pi*[1000; 1000], -2*pi*[0.2; 0.2], (0.2/1000)^2*1e-6), ...
    2*pi*data(:,1)));
data(:,2) = data(:,2) .* abs( intl.imcxfilt);

% Convert IMC_F to Hz
data(:,3) = data(:,3) * 1e3;

% Write name an frequency
nsout.dark.name = 'Electronics Dark Noise';
nsout.dark.f = data(:,1);

% Interpolate ArbLoopTFs
tfx = interp1( ftf.f, ftf.darkXopen, nsout.dark.f);
tff = interp1( ftf.f, ftf.darkFopen, nsout.dark.f);
tfn = interp1( ftf.f, ftf.dark, nsout.dark.f);

% Calculate Input Noise
temp.darkx = data(:,2) ./ abs( tfx);
temp.darkf = data(:,3) ./ abs( tff);

% figure(3)
% clf
% loglog( nsout.dark.f, temp.darkx, 'Color', [0.2, 0.4, 0.4])
% hold on
% loglog( nsout.dark.f, temp.darkf, 'Color', [0.4, 0.2, 0.2])
% hold off

% Multiply TF
nsout.dark.y = temp.darkf .* abs( tfn);


%% VCO Noise
nsout.vco.name = 'VCO Noise';
nsout.vco.f = intl.vco.freq;

% Interpolate ArbLoop TF
tf = interp1( ftf.f, ftf.vco, nsout.vco.f);

% Multiply by TF
nsout.vco.y = abs( tf) .* intl.vco.data;

%% Shot Noise
nsout.shot.name = 'Shot Noise';
nsout.shot.f = intl.shot.freq;

% Interpolate ArbLoop TF
tf = interp1( ftf.f, ftf.shot, nsout.shot.f);

% Multiply by TF
nsout.shot.y = abs( tf) .* intl.shot.data;


%% Periscope Noise
nsout.per.name = 'Injection Bench Vibrations';
nsout.per.f = intl.periscope.freq;

% Interpolate ArbLoop TF
tf = interp1( ftf.f, ftf.freq, nsout.per.f);

% Multiply TF
nsout.per.y = abs( tf) .* intl.periscope.data;

%% Create Total
% Interpolate all others onto radiation pressure
tot.rp = nsout.rp.y;
tot.f = nsout.rp.f;

tot.seis = interp1( nsout.seis.f, nsout.seis.y, tot.f);
tot.seis( isnan( tot.seis)) = 0;

tot.sens = interp1( nsout.sens.f, nsout.sens.y, tot.f);
tot.sens( isnan( tot.sens)) = 0;

tot.dark = interp1( nsout.dark.f, nsout.dark.y, tot.f);
tot.dark( isnan( tot.dark)) = 0;

tot.vco = interp1( nsout.vco.f, nsout.vco.y, tot.f);
tot.vco( isnan( tot.vco)) = 0;

tot.shot = interp1( nsout.shot.f, nsout.shot.y, tot.f);
tot.shot( isnan( tot.shot)) = 0;

tot.per = interp1( nsout.per.f, nsout.per.y, tot.f);
tot.per( isnan( tot.per)) = 0;

nsout.tot.name = 'Total Output Frequency Noise';
nsout.tot.f = tot.f;
nsout.tot.y = sqrt( tot.per.^2 + tot.vco.^2 + tot.dark.^2 + ...
    tot.sens.^2 + tot.seis.^2 + tot.rp.^2);

nsout.tot.style = {'LineWidth', 2, 'LineStyle', '--', 'Color', [0 0 0]};


%% Clean up noises
addpath('../Noise_Budget_Plot/')

[nsout.tot.y, nsout.tot.f] = pwelch_clean( nsout.tot.y, nsout.tot.f, 500);
[nsout.per.y, nsout.per.f] = pwelch_clean( nsout.per.y, nsout.per.f, 500);
[nsout.seis.y, nsout.seis.f] = pwelch_clean( nsout.seis.y, nsout.seis.f, 500);
[nsout.dark.y, nsout.dark.f] = pwelch_clean( nsout.dark.y, nsout.dark.f, 500);
[nsout.rp.y, nsout.rp.f] = pwelch_clean( nsout.rp.y, nsout.rp.f, 500);


%% Plots

intl.clrs = [...
    205 150 205;...
    162 0 255;...
    131 111 255;...
    24  116 205;...
    0   197 205;...
    0   201 87;...
    218 165 32;...
    255 97  3;...
    205 0   0;...
    132 132 132; ...
    0 0 0]/255;

prm.lnwdth = 2;
prm.fntsz = 18;


figure(2)
clf

set(gca,'FontSize',prm.fntsz,...
    'ytick',10.^(-17:-5))

intl.nm = fieldnames(nsout);
intl.lgnd = {};
for j = 1:length(intl.nm)
    now.nm = intl.nm{j};
    if isfield(nsout.(now.nm),'mcx')
        now.data = sqrt(nsout.(now.nm).mcx.^2+...
            nsout.(now.nm).mcf.^2);
    else
        now.data = nsout.(now.nm).y;
    end
    if isfield(nsout.(now.nm),'style')
        loglog(nsout.(now.nm).f, now.data, ...
            nsout.(now.nm).style{:})
    else
        loglog(nsout.(now.nm).f,now.data,...
            'Color',intl.clrs(j,:),...
            'LineWidth',prm.lnwdth)
    end
    hold on
    %-------------------
    intl.lgnd = [intl.lgnd nsout.(now.nm).name];
end
hold off
grid on
legend(intl.lgnd)
xlabel('Frequency (Hz)')
ylabel('Frequency Noise (Hz/rtHz)')
title('Input Mode Cleaner Noise Budget')
xlim([5e-2 2e3])
ylim([1e-6 1e4])

set(gca,'PlotBoxAspectRatio',[11 8.5 1])
