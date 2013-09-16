function out = atomServoDark(par)
% The output is a structure which should have the fields:
%  out.ff      - frequency vector
%  out.asd     - amplitude spectral density
%  out.name    - the name which will show up on the legend
%  out.plotpar - some set of tbd plotting parameters

%-----------------------------------------------------------------%
%%%%%%%%%%%% Define Default Plotting Params   %%%%%%%%%%%%%%%%%%%%%
out.name = 'Servo Dark Noise';
out.plotpar = {'LineWidth', 2, 'Color', [153 0 153]/255};

%-----------------------------------------------------------------%
%%%%%%%%%%%%%%%%%%  Print to Screen   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if par.verbose
    disp('Now generating servo dark noise.')
end


%-----------------------------------------------------------------%
%%%%%%%%%%%%%%%%%%%%%   Parse Inputs  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% *Does this atom need different parameters than the the default set which
%  is passed to it?  Frequency resolution?
if isfield(par, 'dark')
    fldNames = fieldnames(par.dark);
    for jj = 1:length(fldNames);
        par.(fldNames{jj}) = par.dark.(fldNames{jj});
    end
end

%-----------------------------------------------------------------%
%%%%%%%%%%%%%%%%%     Get Reference Data   %%%%%%%%%%%%%%%%%%%%%%%%
% Here we load the noise from a text file in the /l1/couplings 
% directory. IMC_F is stored in column 3 and IMC_X is stored in 
% column 2.  
data = importdata( 'coupServoDark.txt');

% Convert IMC_X to meters and de whiten
intl.imcxfilt = squeeze( freqresp(...
    zpk( -2*pi*[1000; 1000], -2*pi*[0.2; 0.2], (0.2/1000)^2*1e-6), ...
    2*pi*data(:,1)));
data(:,2) = data(:,2) .* abs( intl.imcxfilt);

% Convert IMC_F to meters from kHz
data(:,3) = data(:,3) * 5.7e-11;

% Quadrature sum
out.ff = data(:,1);
out.asd = sqrt( data(:,2).^2 + data(:,3).^2);


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
%== Divide by the total loop gain
% Get the loop gain
load('LoopGain.mat')

% Interpolate onto the correct frequencies
intl.totgn = interp1( loop_gn_f, loop_gn_resp, out.ff);

% Divide the output
out.asd = out.asd .* abs( 1./(1-intl.totgn));


%-----------------------------------------------------------------%
%%%%%%%%%%%%%%%%%    Format Output  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------------------------%
%%%%%%%%%%%%%%%%%%%%%  Save Data  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do you want to save any data?  Where should it be saved?
