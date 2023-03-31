% Read the audio file
[audioSignal,fs] = audioread('piano.m4a');

% Reshape the audio signal to a vector
audioSignal = reshape(audioSignal, [], 1);

% Extract the portion of the signal from 0 to 9 seconds
end_sample = round(9 * fs);
audioSignal = audioSignal(1:end_sample);

% Find the start time of the first non-zero amplitude value
start_time = find(audioSignal ~= 0, 1) / fs;

% Calculate the required length of silence
silence_length = 0.5 - start_time;
silence_samples = round(silence_length * fs);

% Add the calculated silence at the beginning
silence = zeros(silence_samples, 1);
audioSignal = [silence; audioSignal];

% Trim the audio signal back to 9 seconds
audioSignal = audioSignal(1:end_sample);

% Compute the spectrogram
% ... (spectrogram code)

% Plot the original signal with square figure
t = (0:length(audioSignal)-1)/fs;
figure('Position', [100, 100, 500, 500])
plot(t, audioSignal)
xlabel('Time (s)')
ylabel('Amplitude')
title('Original Signal (0-9 seconds) with total 0.5 seconds of silence at the beginning')
