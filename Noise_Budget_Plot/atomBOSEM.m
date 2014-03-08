function out = atomBOSEM(par)
% The output is a structure which should have the fields:
%  out.ff      - frequency vector
%  out.asd     - amplitude spectral density
%  out.name    - the name which will show up on the legend
%  out.plotpar - some set of tbd plotting parameters

%-----------------------------------------------------------------%
%%%%%%%%%%%% Define Default Plotting Params   %%%%%%%%%%%%%%%%%%%%%
out.name = 'BOSEM Noise';
out.plotpar = {'LineWidth', 2, 'Color', [255 128 0]/255};

%-----------------------------------------------------------------%
%%%%%%%%%%%%%%%%%%  Print to Screen   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if par.verbose
    disp('Now calculating BOSEM noise.')
end


%-----------------------------------------------------------------%
%%%%%%%%%%%%%%%%%%%%%   Parse Inputs  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% *Does this atom need different parameters than the the default set which
%  is passed to it?  Frequency resolution?
if isfield(par, 'bosem')
    fldNames = fieldnames(par.bosem);
    for jj = 1:length(fldNames);
        par.(fldNames{jj}) = par.bosem.(fldNames{jj});
    end
end

%-----------------------------------------------------------------%
%%%%%%%%%%%%%%%%%     Get Reference Data   %%%%%%%%%%%%%%%%%%%%%%%%
% This expression for BOSEM noise is taken roughly from T0900496 
% in m/rtHz
% Expression for interpolation
intl.f = [0.1 0.5 1 1e1 1e2 1e3 1e4];
intl.x = [1e-8 3e-10 1.5e-10 6e-11 6e-11 6e-11 6e-11]; 

% Define the frequency vector
out.ff = logspace( -1, log10(20), 1000)';

% Interpolate
out.asd = 10.^( interp1( log10(intl.f), log10(intl.x), log10(out.ff)));

% Convert to microns
out.asd = out.asd*1e6;


%-----------------------------------------------------------------%
%%%%%%%%%%%%%%%%%     Get Machine State    %%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------------------------%
%%%%%%%%%%%%%%%%%     Get Current Data     %%%%%%%%%%%%%%%%%%%%%%%%
    
%-----------------------------------------------------------------%
%%%%%%%%%%%%%%%%%    Time Domain Calculations    %%%%%%%%%%%%%%%%%%

%-----------------------------------------------------------------%
%%%%%%%%%%%%%%   Calculate Power Spectrum   %%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------------------------%
%%%%%%%%%%%%%%%%   Frequency Domain Calculation   %%%%%%%%%%%%%%%%%
% Import measured transfer function.  This transfer function is only 
% valid below 20 Hz.
data = importdata('coupBosem.txt');

data2(:,1) = data(:,1);
data2(:,2) = data(:,2) + 1i*data(:,3);
data2(:,3) = data(:,4) + 1i*data(:,5);

% Convert IMC_X to meters and de whiten
intl.imcxfilt = squeeze( freqresp(...
    zpk( -2*pi*[1000; 1000], -2*pi*[0.2; 0.2], (0.2/1000)^2*1e-6), ...
    2*pi*data(:,1)));
data2(:,2) = data2(:,2) .* abs( intl.imcxfilt);

% Convert IMC_F to meters from kHz
data2(:,3) = data2(:,3) * 5.7e-11;

% Interpolate measured tfs onto out.ff
intl.imcxtf = interp1( data2(:,1), data2(:,2), out.ff);
intl.imcftf = interp1( data2(:,1), data2(:,3), out.ff);

% Propogate noise through tfs
intl.imcxn = out.asd .* intl.imcxtf;
intl.imcfn = out.asd .* intl.imcftf;

% Quadrature sum
out.asd = sqrt( abs(intl.imcxn).^2 + abs(intl.imcfn).^2);


%-----------------------------------------------------------------%
%%%%%%%%%%%%%%%%%    Format Output  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------------------------%
%%%%%%%%%%%%%%%%%%%%%  Save Data  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do you want to save any data?  Where should it be saved?
















