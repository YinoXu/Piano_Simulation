%piano.m
clear all
% Specify the music to be played:
%nmax = 15; % Number of notes
tnote_1 = [0.5, 1, 1.5, 2.0, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7.25, 7.5]; % Onset times of the notes (s)
tnote_2 = [0.5, 0.5, 2.5, 2.5, 4.5, 4.5, 5.5, 6.0, 6.5];
dnote_1 = [0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.9, 0.3, 1.2]; % Durations of the notes (s)
dnote_2 = [2.4, 2.4, 2.4, 2.4, 1.2, 1.2, 0.6, 0.6, 2.4];
anote_1 = [0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8]; % Relative amplitudes of the notes
anote_2 = [0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8];
inote_1 = [20, 20, 21, 23, 23, 21, 20, 18, 16, 16, 18, 20, 20, 18, 18]; % String indices of the notes
inote_2 = [4, 11, 3, 11, 8, 11, 6, 4, 11];
nmax = length(tnote_1)+length(tnote_2);

[tnote, dnote, anote, inote] = merge(tnote_1, tnote_2, dnote_1, dnote_2, anote_1, anote_2, inote_1, inote_2);



%tnote = cat(2, tnote_1, tnote_2);
%tnote = [0.5, 0.5, 1.0, 1.5, 2.0, 2.5, 2.5, 3.0, 3.5, 4.0, 4.5, 4.5, 5.0, 5.5, 6.0, 6.5, 6.5, 7.25, 7.5]; % Onset times of the notes (s)
%dnote = cat(2, dnote_1, dnote_2);
%dnote = [0.6, 2.4, 0.6, 0.6, 0.6, 0.6, 2.4, 0.6, 0.6, 0.6, 0.6, 2.4, 0.6, 0.6, 0.6, 0.9, 2.4, 0.3, 1.2]; % Durations of the notes (s)
%anote = cat(2, anote_1, anote_2);
%anote = [0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8]; % Relative amplitudes of the notes
%inote = cat(2, inote_1, inote_2);
%inote = [20, 4, 20, 21, 23, 23, 11,  21, 20, 18, 16, 4, 16, 18, 20, 20, 11, 18, 18]; % String indices of the notes

%initialize string parameters:
L=1; % length of all strings
J=81;dx=L/(J-1); %number of points/string, space step
flow = 220; %frequency of string with lowest pitch (1/s)
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
soundsc(S(1:count)) %listen to the sound
save('S');
plot(tsave(1:count),S(1:count)) %plot the soundwave