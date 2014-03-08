% This script plots the noise budget from February 5th with some
% corrections.

clear all

%% Load the data
load IMC_NB_Data_Feb_05_2013.mat

%% Reference Cavity Noise


%% DeWhiten IMC_X
intl.mcx.filt = zpk(-2*pi*[1000 1000],-2*pi*[0.2 0.2],0.2^2/1000^2);
intl.mcx.mag = abs( squeeze( freqresp( intl.mcx.filt, 2*pi*nsin.mcx.f)));

nsin.mcx.y = nsin.mcx.y .* intl.mcx.mag;

%% Get BOSEM Noise
par.verbose = 0;

nsin.sens = rmfield(nsin.sens, {'mcx','mcf'});

clear temp
temp = atomBOSEM(par);

nsin.sens.y = temp.asd;
nsin.sens.f = temp.ff;

%% Get Servo Dark Noise
clear temp
temp = atomServoDark(par);

nsin.servo = rmfield(nsin.servo, {'mcx', 'mcf'});

nsin.servo.y = temp.asd;
nsin.servo.f = temp.ff;

%% Clean Some of the Noises
[nsin.mcx.y, nsin.mcx.f] = pwelch_clean( nsin.mcx.y.^2, nsin.mcx.f, 500);
nsin.mcx.y = sqrt( nsin.mcx.y);

[nsin.mcf.y, nsin.mcf.f] = pwelch_clean( nsin.mcf.y.^2, nsin.mcf.f, 500);
nsin.mcf.y = sqrt( nsin.mcf.y);

nsin.periscope.y = sqrt( nsin.periscope.mcx.^2 + nsin.periscope.mcf.^2);
nsin.periscope = rmfield( nsin.periscope, {'mcx', 'mcf'});
[nsin.periscope.y, nsin.periscope.f] = pwelch_clean( nsin.periscope.y.^2, ...
    nsin.periscope.f, 500);
nsin.periscope.y = sqrt( nsin.periscope.y);

nsin.seis.y = sqrt( nsin.seis.mcx.^2 + nsin.seis.mcx.^2);
nsin.seis = rmfield( nsin.seis, {'mcx', 'mcf'});
[nsin.seis.y, nsin.seis.f] = pwelch_clean( nsin.seis.y.^2, nsin.seis.f, ...
    500);
nsin.seis.y = sqrt( nsin.seis.y);

[nsin.servo.y, nsin.servo.f] = pwelch_clean( nsin.servo.y.^2, nsin.servo.f, 500);
nsin.servo.y = sqrt( nsin.servo.y);

nsin.rp.y = sqrt( nsin.rp.mcx.^2 + nsin.rp.mcf.^2);
nsin.rp = rmfield( nsin.rp, {'mcx', 'mcf'});
[nsin.rp.y, nsin.rp.f] = pwelch_clean( nsin.rp.y.^2, nsin.rp.f, 500);
nsin.rp.y = sqrt( nsin.rp.y);


%% Create Totals
clear temp
nsin.totin.name = 'Total Measured Noise';
if length( nsin.mcx.f) < length( nsin.mcf.f);
    nsin.totin.f = nsin.mcx.f;
    temp = interp1( nsin.mcf.f, nsin.mcf.y, nsin.mcx.f);
    nsin.totin.y = sqrt( temp.^2 + nsin.mcx.y.^2);
else
    nsin.totin.f = nsin.mcf.f;
    temp = interp1( nsin.mcx.f, nsin.mcx.y, nsin.mcf.f);
    nsin.totin.y = sqrt( temp.^2 + nsin.mcf.y.^2);
end

clear temp1 temp2
temp1 = interp1( nsin.seis.f, nsin.seis.y, nsin.periscope.f);
temp1( isnan( temp1)) = 0;
temp2 = interp1( nsin.sens.f, nsin.sens.y, nsin.periscope.f);
temp2( isnan( temp2)) = 0;

nsin.known.name = 'Total of Known Noises';
nsin.known.f = nsin.periscope.f;
nsin.known.y = sqrt( temp1.^2 + temp2.^2 + nsin.periscope.y.^2);

%% Change some of the names
nsin.servo.name = 'Electronics Dark Noise';
nsin.periscope.name = 'Injection Bench Vibration';
nsin.mcx.name = 'Length Control Signal';
nsin.mcf.name = 'Frequency Control Signal';
nsin.sens.name = 'Damping Sensor Noise';


%% Save the Results
save( 'NB_Data_Processed.mat', 'nsin')
















