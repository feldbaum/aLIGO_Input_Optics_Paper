% This script will calculate the transfer functions from the noise inputs
% to frequency at the output of the input mode cleaner and save them in a
% .mat file.

%% Choose Some Settings.
clear all

% Do you want to plot the TFs at the end to check?
plotFlag = 1;

% Do you need to recalculate the TFs or simply load and plot?
calcFlag = 1;

% Choose a frequency vector.  We will interpolate the transfer functions
% onto the necessary frequency points of the noise sources from this
% frequency vector.
f = logspace(-3, 4, 5000)';

%% Load the ArbLoop Model
addpath(genpath('C:\Users\Chris Mueller\Documents\Research\Ligo\Modeling_Tools\iscmodeling\ArbLoop'))

loop = ArbLoop_IMC_Simple();

%% Calculate Transfer Functions
if calcFlag
    ftf.f = f;
    
    % Frequency Noise
    ftf.freq = getTF( loop, 'Freq Noise', 'Trans Freq', f);

    % Length Noise
    ftf.length = getTF( loop, 'Length In', 'Trans Freq', f);

    % Radiation Pressure
    ftf.rp = getTF( loop, 'Radiation Pressure', 'Trans Freq', f);

    % BOSEM Noise
    ftf.sens = getTF( loop, 'BOSEM Noise', 'Trans Freq', f);

    % VCO Noise
    ftf.vco = getTF( loop, 'VCO Noise', 'Trans Freq', f);

    % Shot Noise
    ftf.shot = getTF( loop, 'Shot Noise', 'Trans Freq', f);

    % ISI Disp
    ftf.seis = getTF( loop, 'ISI Disp', 'Trans Freq', f);
    
    % Dark Noise Open Loop Calculations
    [~, loop2, nameIn1, nameOut1] = getOLTF( loop, 'CMS: Gain 1', f, ...
        'noTF', 1);
    [~, loop2, nameIn2, nameOut2] = getOLTF( loop2, 'VCO: Doub', f, ...
        'noTF', 1, 'breakAfter', 1);
    [~, loop2, nameIn3, nameOut3] = getOLTF( loop2, 'MC2: Cav Disp', f, ...
        'noTF', 1, 'breakAfter', 1);
    ftf.darkXopen = getTF( loop2, nameIn1, nameOut3, f);
    ftf.darkFopen = getTF( loop2, nameIn1, nameOut2, f);
    
    % Dark Noise
    ftf.dark = getTF( loop, 'Dark Noise', 'Trans Freq', f);
    
    % Save the TFs
    save('Frequency_Noise_Tfs.mat', 'ftf')

else
    load('Frequency_Noise_Tfs.mat')
end


%% Plot to Check

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

figure(1)
clf

subplot(211)
set(gca,'FontSize',prm.fntsz,...
    'ytick',10.^(-17:-5))
subplot(212)
set(gca,'FontSize',prm.fntsz,...
    'ytick',10.^(-17:-5))


intl.nm = fieldnames(ftf);
intl.nm = intl.nm( ~strcmp( intl.nm, 'f'));



for j = 1:length(intl.nm)
    loopn.nm = intl.nm{j};
    subplot(211)
    semilogx(ftf.f,20*log10( abs(ftf.(loopn.nm))),...
        'Color',intl.clrs(j,:),...
        'LineWidth',prm.lnwdth)
    hold on

    subplot(212)
    plotPhs(ftf.f, 180/pi*angle( ftf.(loopn.nm)),...
        'Color',intl.clrs(j,:),...
        'LineWidth',prm.lnwdth)
    hold on     
end

subplot(211)
xlim([min(ftf.f) max(ftf.f)])
grid on
legend(intl.nm, 'Location', 'SouthWest')

subplot(212)
xlim([min(ftf.f) max(ftf.f)])
ylim([-180 180])
grid on



    


























