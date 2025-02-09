function bpseg = bandpass_filter(seg, freq, h)

%
% bandpassSeg = bandpass_filter(seg, freq)
% bandpassSeg = bandpass_filter(seg, freq, h)
%
% INPUTS:
% 
% SEG can be vector or matrix. Each column is one channel.
% FREQ is the cut-off frequency. Must be in the range of [0 fn] where fn is
%      the nyquist frequency (sample rate/2). Values of freq will
%      automatically fit in the range of  0 < freq < fn if saturated.
% H is the sample frequency. Default is HDR.SampleRate in matlabs base 
% workspace or 128 if HDR does not exist in workspace. 
%
% OUTPUTS:
%
% BandPass Segmation is the filtered signals.

%
% Bandpass filter the two EEG signals of s between 0 and 30 seconds that



if nargin==2
    try
        HDR=evalin('base','HDR');
        h=HDR.SampleRate;
    catch
        h=128;
    end
end

filtorder = 2;

if freq(1) > 0 && freq(2) >= h/2
    [b, a] = butter(filtorder, freq(1)*(2/h), 'high');
elseif freq(1) <= 0 && freq(2) < h/2
    [b, a] = butter(filtorder, freq(2)*(2/h), 'low');
elseif freq(1) > 0 && freq(2) < h/2
    [b, a] = butter(filtorder, freq*(2/h));
else
    disp('ERROR: Cut-off frequency');
    return
end

bandpass_filter= filtfilt(b, a, seg);

%disp(['Filtered successfully with a: ' num2str(a) ' b: ' num2str(b)]);

end

