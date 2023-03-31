% ---------- Add the piano.m code here ----------
%piano.m
clear all
% Specify the music to be played:
nmax = 15; % Number of notes
tnote = [0.5, 1, 1.5, 2.0, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7.25, 7.5]; % Onset times of the notes (s)
dnote = [0.7, 0.7, 0.7, 0.7, 0.7, 0.7, 0.7, 0.7, 0.7, 0.7, 0.7, 0.7, 0.9, 0.2, 0.8]; % Durations of the notes (s)
anote = [0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8]; % Relative amplitudes of the notes
inote = [8, 8, 9, 11, 11, 9, 8, 6, 4, 4, 6, 8, 8, 6, 6]; % String indices of the notes

%initialize string parameters:
L=1; % length of all strings
J=81;dx=L/(J-1); %number of points/string, space step
flow = 300; %frequency of string with lowest pitch (1/s)
nstrings = 25; %number of strings
for i=1:nstrings
    f(i)=flow*2^((i-1)/12); % frequency (1/s)
    tau(i)=1.2*(440/f(i)); % decay time (s)
    M(i)=1; % mass/length
    T(i)=M(i)*(2*L*f(i))^2; % tension
    R(i)=(2*M(i)*L^2)/(tau(i)*pi^2); % damping constant
    %Find the largest stable timestep for string i:
    dtmax(i) = - R(i)/T(i) + sqrt((R(i)/T(i))^2 + dx^2/(T(i)/M(i)));
end
%The timestep of the computation has to be stable for all strings:
dtmaxmin = min(dtmax);
%Now set dt and nskip such that:
%dt<=dtmaxmin, nskip is a positive integer, and dt*nskip = 1/8192.
%Also, make nskip as small as possible, given the above criteria.
nskip = ceil(1/(8192*dtmaxmin));
dt=1/(8192*nskip);
tmax=tnote(nmax)+dnote(nmax); clockmax=ceil(tmax/dt);
%initialize an array that will be used to tell a string
%when to stop vibrating:
tstop=zeros(nstrings,1);
%initialize arrays to store state of the strings:
H=zeros(nstrings,J);
V=zeros(nstrings,J);

%(xh1,xh2)=part of string hit by hammer:
xh1=0.25*L;xh2=0.35*L;
%list of points hit by hammer:
jstrike=ceil(1+xh1/dx):floor(1+xh2/dx);
j=2:(J-1); %list of interior points
%initialize array to store soundwave:
count=0; %initialize count of samples of recorded soundwave
S=zeros(1,ceil(clockmax/nskip)); %array to record soundwave
tsave = zeros(1,ceil(clockmax/nskip)); %array for times of samples

n=1 ; %initialize note counter
for clock=1:clockmax
    t=clock*dt;
    while((n<=nmax) && tnote(n)<=t)
        V(inote(n),jstrike)=anote(n); %strike string inote(n)
        %with amplitude anote(n)
        tstop(inote(n))=t+dnote(n); %record future stop time
        n=n+1; %increment note counter
    end
    for i=1:nstrings
        if(t > tstop(i))
            H(i,:)=zeros(1,J);
            V(i,:)=zeros(1,J);
        else
            V(i,j)=V(i,j) ...
                +(dt/dx^2)*(T(i)/M(i))*(H(i,j+1)-2*H(i,j)+H(i,j-1)) ...
                +(dt/dx^2)*(R(i)/M(i))*(V(i,j+1)-2*V(i,j)+V(i,j-1));
            H(i,j)=H(i,j)+dt*V(i,j);
        end
    end
    if(mod(clock,nskip)==0)
        count=count+1;
        S(count)=sum(H(:,2)); %sample the sound at the present time
        tsave(count)=t; %record the time of the sample
    end
end
% soundsc(S(1:count)) %listen to the sound
% plot(tsave(1:count),S(1:count)) %plot the soundwave

% Normalize the synthesized sound from piano.m
normalized_S = S(1:count) / max(abs(S(1:count)));

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



% Normalize the original signal
normalized_audioSignal = audioSignal / max(abs(audioSignal));


% Plot the normalized synthesized sound from piano.m and the normalized original signal in the same figure
figure('Position', [100, 100, 800, 400])

% Plot the synthesized sound from piano.m
subplot(2,1,1)
plot(tsave(1:count), normalized_S)
xlabel('Time (s)')
ylabel('Amplitude')
title('Normalized Synthesized Sound from piano.m')

% Plot the original signal
t = (0:length(audioSignal)-1)/fs;
subplot(2,1,2)
plot(t, normalized_audioSignal)
xlabel('Time (s)')
ylabel('Amplitude')
title('Normalized Original Signal (0-9 seconds)')

% Match y-axis limits for both subplots
minAmplitude = min(min(normalized_S), min(normalized_audioSignal));
maxAmplitude = max(max(normalized_S), max(normalized_audioSignal));
subplot(2,1,1)
ylim([minAmplitude, maxAmplitude])
subplot(2,1,2)
ylim([minAmplitude, maxAmplitude])
