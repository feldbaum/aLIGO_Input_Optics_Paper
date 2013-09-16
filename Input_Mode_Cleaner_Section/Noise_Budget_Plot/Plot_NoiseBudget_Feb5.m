%% Load the Processed Data

load NB_Data_Processed.mat

%% Choose Some Specific Styles
nsin.known.style = {'Color', [0 0 0], 'LineWidth', 2, 'LineStyle', '--'};

nsin.totin.style = {'Color', [0.4 0.4 0.4], 'LineWidth', 2, 'LineStyle', '--'};

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

prm.lnwdth = 1;
prm.fntsz = 18;


figure(1)
clf

set(gca,'FontSize',prm.fntsz,...
    'ytick',10.^(-17:-5))

intl.nm = fieldnames(nsin);
intl.lgnd = {};
for j = 1:length(intl.nm)
    loop.nm = intl.nm{j};
    if isfield(nsin.(loop.nm),'mcx')
        loop.data = sqrt(nsin.(loop.nm).mcx.^2+...
            nsin.(loop.nm).mcf.^2);
    else
        loop.data = nsin.(loop.nm).y;
    end
    if isfield(nsin.(loop.nm),'style')
        loglog(nsin.(loop.nm).f, loop.data, ...
            nsin.(loop.nm).style{:})
    else
        loglog(nsin.(loop.nm).f,loop.data,...
            'Color',intl.clrs(j,:),...
            'LineWidth',prm.lnwdth)
    end
    hold on
    %-------------------
    intl.lgnd = [intl.lgnd nsin.(loop.nm).name];
end
hold off
grid on
legend(intl.lgnd)
xlim([5e-2 2e3])
ylim([1e-17 1e-5])
xlabel('Frequency (Hz)')
ylabel('Length Noise (m/rtHz)')
title('Input Mode Cleaner Noise Budget')

set(gca,'PlotBoxAspectRatio',[11 8.5 1])

orient landscape
print -dpdf ../IMC_Noise_Budget.pdf









