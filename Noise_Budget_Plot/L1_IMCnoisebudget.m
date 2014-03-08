% Producing the noise budget for IMC
%          by   Chris. M, Anamaria. E, and Keiko. K
%          2012 July 30
%
% 1 seismic noise propagates ISI ----> M1. M1 ---> M3 transfer function
%      - get the TF HSTS from M1 to M3
%
% 2 OSEM sensor noise  = sensor noise propages to the DoF monitor ./closed loop
%   - Make the closed loop
%    o get the list of foton files
%    o get the active FM filter numbers
%    o get the frequency response of the active FM filters
%    o make the closed loop
% 
%
% 3 RP noise budget = RIN --> RP --> Force to displacement TF
%  - get the PSL-ISS-PDS
%  - FFT
%  - convert to RIN
%  - get the Force to disp TF
%
% 4 Frequency is the estimation of VCO noise
% 
% 5 suspension thermal noise  - added by KK 02/2013
%
% 6. Frequency control noise
%
% 7. PSL periscope vibration-induced phase noise
%   - Added by ZK, 10/2012
%


% USAGE!!!
% regenIMC needs to be set to 1 if you want to regenerate the IMC state
% space model.




clear all
close all

cd /data/NB/IMC/l1

%% Set Optional Parameters
prm.regenIMC = 0; %Do you want to regenerate the IMC model
prm.time = 1044170933;
prm.duration = 256;
prm.freq = logspace(-2, 4, 1000);
prm.conv = 8.5521e12*2;
prm.ifo = 'L1';

%% Add paths
addpath('/ligo/svncommon/SusSVN/sus/trunk/Common/MatlabTools/TripleModel_Production')

%All subdirectories
addpath(genpath('/data/NB/IMC/common'))

%% Generate/Load IMC
if prm.regenIMC
    cd ../common/Generate_IMC
    Generate_IMC
    load IMC_SS.mat
    cd ../..
    cd l1/
else
    cd ../common/Generate_IMC
    load IMC_SS.mat
    cd ../..
    cd ./l1/
end


%% Seismic Noise
% The siesmic noise currently uses Ryan DeRosa's measured ISI to cavity
% transfer functions which it gets from his local directory. It is
% therefore length noise at the cavity, not seismic noise in terms of the
% model.  

intl.seis = mcnoise_Seismic(prm.time,prm.ifo);

nsin.seis.name = 'Seismic';
nsin.seis.f = intl.seis.freq;
nsin.seis.mcx = freqSpace_Filtering(intl.seis.data,nsin.seis.f,imc.ss(2,2));
nsin.seis.mcf = freqSpace_Filtering(intl.seis.data,nsin.seis.f,imc.ss(3,2))*...
    1/prm.conv;


nsout.seis.name = 'Seismic';
nsout.seis.f = intl.seis.freq;
nsout.seis.y = freqSpace_Filtering(intl.seis.data,nsout.seis.f,imc.ss(1,2));


%% RP budget
intl.rp = mcnoise_RadPres(prm.time,prm.ifo);       

nsin.rp.name = 'Radiation Pressure';
nsin.rp.f = intl.rp.fdom.freq;
nsin.rp.mcx = freqSpace_Filtering(intl.rp.fdom.data,nsin.rp.f,imc.ss(2,5));
nsin.rp.mcf = freqSpace_Filtering(intl.rp.fdom.data,nsin.rp.f,imc.ss(3,5))*...
    1/prm.conv;

nsout.rp.name = 'Radiation Pressure';
nsout.rp.f = nsin.rp.f;
nsout.rp.y = freqSpace_Filtering(intl.rp.fdom.data,nsout.rp.f,imc.ss(1,5));

%% BOSEM noise

intl.sens = mcnoise_BOSEM(prm.time,prm.ifo);

nsin.sens.name = 'BOSEM Noise';
nsin.sens.f = intl.sens.freq;
nsin.sens.mcx = freqSpace_Filtering(intl.sens.data,nsin.sens.f,imc.ss(2,6));
nsin.sens.mcf = freqSpace_Filtering(intl.sens.data,nsin.sens.f,imc.ss(3,6))*...
    1/prm.conv;

nsout.sens.name = 'BOSEM Noise';
nsout.sens.f = nsin.sens.f;
nsout.sens.y = freqSpace_Filtering(intl.sens.data,nsout.sens.f,imc.ss(1,6));

%% Servo noise
% Measurement, inferred to the front of the servo

intl.servo = mcnoise_Servo;

nsin.servo.name = 'Servo Noise';
nsin.servo.f = intl.servo.freq;
nsin.servo.mcx = freqSpace_Filtering(intl.servo.data,nsin.servo.f,imc.ss(2,8));
nsin.servo.mcf = freqSpace_Filtering(intl.servo.data,nsin.servo.f,imc.ss(3,8))*...
    1/prm.conv;

nsout.servo.name = 'Servo Noise';
nsout.servo.f = nsin.servo.f;
nsout.servo.y = freqSpace_Filtering(intl.servo.data,nsout.servo.f,imc.ss(1,8));

%% VCO noise estimate

intl.vco = mcnoise_VCO(prm.time,prm.ifo);

nsin.vco.name = 'VCO Noise';
nsin.vco.f = intl.vco.freq;
nsin.vco.mcx = freqSpace_Filtering(intl.vco.data,nsin.vco.f,imc.ss(2,7));
nsin.vco.mcf = freqSpace_Filtering(intl.vco.data,nsin.vco.f,imc.ss(3,7))*...
    1/prm.conv;

nsout.vco.name = 'VCO Noise';
nsout.vco.f = nsin.vco.f;
nsout.vco.y = freqSpace_Filtering(intl.vco.data,nsout.vco.f,imc.ss(1,7));


%% Shot noise
intl.shot = mcnoise_Shot(prm.time,prm.ifo);

nsin.shot.name = 'Shot Noise';
nsin.shot.f = intl.shot.freq;
nsin.shot.mcx = freqSpace_Filtering(intl.shot.data,nsin.shot.f,imc.ss(2,3));
nsin.shot.mcf = freqSpace_Filtering(intl.shot.data,nsin.shot.f,imc.ss(3,3))*...
    1/prm.conv;

nsout.shot.name = 'Shot Noise';
nsout.shot.f = intl.shot.freq;
nsout.shot.y = freqSpace_Filtering(intl.shot.data,nsout.shot.f,imc.ss(1,3));

%% Periscope vibration
intl.periscope = mcnoise_Periscope(prm.time,prm.ifo);

nsin.periscope.name = 'PSL Periscope Vibration';
nsin.periscope.f = intl.periscope.freq;
nsin.periscope.mcx = freqSpace_Filtering(intl.periscope.data,nsin.periscope.f,imc.ss(2,1));
nsin.periscope.mcf = freqSpace_Filtering(intl.periscope.data,nsin.periscope.f,imc.ss(3,1))*...
    1/prm.conv;

nsout.periscope.name = 'PSL Periscope Vibration';
nsout.periscope.f = intl.periscope.freq;
nsout.periscope.y = freqSpace_Filtering(intl.periscope.data,nsout.periscope.f,imc.ss(1,1));

%% Control Noise MC_F
intl.mcf = mcnoise_IMC_F(prm.time,prm.ifo);

nsin.mcf.name = 'IMC_F';
nsin.mcf.f = intl.mcf.freq;
nsin.mcf.y = intl.mcf.data*1/prm.conv;

% nsout.mcf.name = 'IMC_F';
% nsout.mcf.f = nsin.mcf.f;
% nsout.mcf.y = freqSpace_Filtering(intl.mcf.data,nsout.mcf.f,imc.ss(1,10));

%% Control Noise MC_X
intl.mcx = mcnoise_IMC_X(prm.time,prm.ifo);

nsin.mcx.name = 'IMC_X';
nsin.mcx.f = intl.mcx.freq;
nsin.mcx.y = intl.mcx.data;

% nsout.mcx.name = 'IMC_X';
% nsout.mcx.f = nsin.mcx.f;
% nsout.mcx.y = freqSpace_Filtering(intl.mcx.data,nsout.mcx.f,imc.ss(1,9));


%% Suspension thermal noise
% single pendulum model as an approximation

intl.susptherm = mcnoise_susptherm(prm.time);

nsin.susptherm.name = 'Suspension Thermal Noise';
nsin.susptherm.f = intl.susptherm.f';
nsin.susptherm.mcx = freqSpace_Filtering(intl.susptherm.noiseL, nsin.susptherm.f, imc.ss(2,2));
nsin.susptherm.mcf = freqSpace_Filtering(intl.susptherm.noiseL, nsin.susptherm.f, imc.ss(3,2))*...
    1/prm.conv;

nsout.susptherm.name = 'Suspension Thermal Noise';
nsout.susptherm.f = intl.susptherm.f';
nsout.susptherm.y = freqSpace_Filtering(intl.susptherm.noiseL, nsout.susptherm.f, imc.ss(1,2));


%% Requriements
intl.reqs = mcnoise_Reqs(prm.time,prm.ifo);

nsout.reqs.name = 'Requirements';
nsout.reqs.f = intl.reqs.freq;
nsout.reqs.y = intl.reqs.data;

%% ELIGO Noise
% eligo=importdata('mcfS6.txt');
% eligof=eligo(:,1);
% eligod=eligo(:,2)*1/(2*8.6e12);


%% Add dark noise (AE)
% measured for 2dB common gain, first boost on
% see /home/anamaria.effler/Matlab/IMC/IMCdarknoise.m for calculation

% load /home/anamaria.effler/Matlab/IMC/darkn_imc2dB.mat


%% Plotting part

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
    



figure(1)
clf

prm.lnwdth = 2;
prm.fntsz = 12;

set(gca,'FontSize',prm.fntsz)
intl.nm = fieldnames(nsout);
intl.lgnd = {};
for j=1:length(intl.nm);
    loop.nm = intl.nm{j};
    loglog(nsout.(loop.nm).f,nsout.(loop.nm).y,...
        'Color',intl.clrs(j,:),...
        'LineWidth',prm.lnwdth);
    hold on
    %------------------
    intl.lgnd = [intl.lgnd nsout.(loop.nm).name];
end
hold off
xlim([5e-2 1e3])
ylim([1e-6 1e5])
grid on
legend(intl.lgnd)
xlabel('Frequency (Hz)')
ylabel('Frequency Noise (Hz/rtHz)')
title('Mode Cleaner Output Frequency Noise')


figure(2)
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
    loglog(nsin.(loop.nm).f,loop.data,...
        'Color',intl.clrs(j,:),...
        'LineWidth',prm.lnwdth)
    hold on
    %-------------------
    intl.lgnd = [intl.lgnd nsin.(loop.nm).name];
end
hold off
grid on
legend(intl.lgnd)
xlim([5e-2 1e4])
ylim([1e-17 1e-5])
xlabel('Frequency (Hz)')
ylabel('Length Noise (m/rtHz)')
title('Mode Cleaner In Loop Noise Budget')

%% Make PDF and save data
[~,temp.date] = system(['tconvert -l ' sprintf('%0.0u',prm.time)]);
intl.date = strrep(temp.date,' ','_');
intl.date = intl.date(1:(length(intl.date)-2));


intl.flnm1 = ['IMC_NB_InLoop_' intl.date '.pdf'];
figure(2)
orient landscape
print(gcf,'-dpdf',intl.flnm1)
movefile(intl.flnm1,'./Data_Archive/NoiseBudget_In/')

intl.flnm2 = ['IMC_NB_Output_' intl.date '.pdf'];
figure(1)
orient landscape
print(gcf,'-dpdf','-append',intl.flnm2)
movefile(intl.flnm2,'./Data_Archive/NoiseBudget_Out/')

intl.flnm3 = ['IMC_NB_Data_' intl.date '.mat'];
save(intl.flnm3,'nsin','nsout','temp');
movefile(intl.flnm3,'./Data_Archive/Data/');


intl.flnm4 = ['IMC_NB_Internal_Data_' intl.date '.mat'];
save(intl.flnm4,'intl');
movefile(intl.flnm4,'./Data_Archive/Data/');













































