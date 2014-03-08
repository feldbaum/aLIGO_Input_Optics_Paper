% [nLong, nPitch, nYaw] = seisSUS(f, susType)
%   get noise source spectra for various suspensions
%
% nLong - mirror longitudinal motion (e.g., beam-line)
% nPitch, nYaw - mirror rotational motion (pitch and yaw)
%
% Example:
% f = logspace(-1,log10(30),300);
% loglog(f, [seisSUS(f, 'QUAD'), seisSUS(f, 'BSFM'), ...
%   seisSUS(f, 'HLTS'), seisSUS(f, 'HSTS')])
% legend('QUAD', 'BSFM', 'HLTS', 'HSTS'); grid on
%
% see also seisBSC, seisHAM, seisGround

function [nLong, nPitch, nYaw] = seisSUS(f, susType)

  % load quad model
  if ~ischar(susType)
    error('susType must be a string: QUAD, BSFM, HLTS, HSTS')
  end
  
  % should contain susSS state-space model
  sus = load([susType '_SS.mat']);
  
  % output index array
  if isfield(sus.out, 'long_tm')
    nOut = [sus.out.long_tm, sus.out.pitch_tm, sus.out.yaw_tm];
  else
    nOut = [sus.out.long_bot, sus.out.pitch_bot, sus.out.yaw_bot];
  end
  
  % input index array
  nIn = [sus.in.long_gnd, sus.in.trans_gnd, sus.in.vert_gnd, ...
    sus.in.pitch_gnd, sus.in.yaw_gnd, sus.in.roll_gnd];
  
  % get all TFs from the model, and make abs^2 for summing noise
  f = f(:);
  sw = warning('off', 'Control:transformation:StateSpaceScaling');
  h2 = permute(abs(freqresp(sus.ss(nOut, nIn), 2*pi*f)).^2, [3, 2, 1]);
  warning(sw);
  
  % split into long, pitch, yaw
  hl2 = h2(:, :, 1);
  hp2 = h2(:, :, 2);
  hy2 = h2(:, :, 3);
  
  % get noise inputs
  bscList = {'QUAD', 'BSFM'};
  if any(strcmp(sus.name, bscList))
    % BSC ISI noise
    [nX, nRX] = seisBSC(f);
    
    % all displacement noises are the same, and
    % all rotational noises are the same (really?)
    %
    % long, trans, vert, pitch, yaw, roll
    n2 = [nX, nX, nX, nRX, nRX, nRX].^2;
  else
    % HAM ISI noise
    [nX, nZ, nRX, nRZ] = seisHAM(f);
    
    % here X and Y are the same, but not Z
    n2 = [nX, nX, nZ, nRX, nRZ, nRX].^2;
  end
  
  % sum up the noises
  nLong = sqrt(sum(hl2 .* n2, 2));
  nPitch = sqrt(sum(hp2 .* n2, 2));
  nYaw = sqrt(sum(hy2 .* n2, 2));
  
end
