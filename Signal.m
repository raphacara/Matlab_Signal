%%% Made by Raphaël Carabeuf
clc 
clf

%% Data initialization
audioFile = '101.wav';
info = audioinfo(audioFile);
[audioSignal, samplingRate] = audioread(audioFile);

minIndex = 0;
maxIndex = 0;
index = 0;
    
for i = 1:length(audioSignal)
    if audioSignal(i) > 0.2
        minIndex = i
        break
    end
end
for i = minIndex:length(audioSignal)
    if audioSignal(i) < 0.2
        maxIndex = i-1
        break
    end
end

audioSignal = audioSignal(minIndex:maxIndex);

plot(audioSignal)
xlabel('Time (s)')
ylabel('Amplitude (V)')
%Limites des BPM
minBPM = 0.5; % 0.5 HZ = 30 BPM
maxBPM = 2;   % 2HZ = 120 BPM

% Nombre de fenêtre
windowsNumber = 4;

averageBPM = 0 ;
for i = 1:windowsNumber

    %Initialisation des variables
    audioSignal = audioSignal - mean(audioSignal); % centre le signal sur 0
    numberOfPoints = length(audioSignal)
    t = (0:numberOfPoints-1)/samplingRate; 
    f=(0:numberOfPoints-1)/numberOfPoints*samplingRate;
    te = 1/samplingRate

    window = audioSignal(round((i-1)/windowsNumber*numberOfPoints+1):round(i/windowsNumber*numberOfPoints));
    windowLength = length(window);
    windowFrequency = (0:windowLength-1)*(samplingRate/windowLength);
    window = window - mean(window); % normalisation de la fenêtre
    
    figure
    plot(windowFrequency, window)
    xlabel('Time (s)')
    ylabel('Amplitude (V)')
    windowFFT = abs(fft(window));
    
    figure
    stem(windowFrequency, windowFFT)
    xlim([minBPM, maxBPM])
    xlabel('Frequency (Hz)')
    ylabel('Amplitude (dB)')

    highestPoint = 0;
    bpmPoint = 0;
    % 360 Hz de plage de fréquence => 1 point équivault à 360/1276 = 0.282 Hz
    % 0.5 Hz se trouve juste après le premier point et 2 Hz à 2/0,282 ~8 mais on mets 10
    frequencyPerPoint = samplingRate/length(windowFFT)
    
    minPoint = 0;
    maxPoint = 0;
    for point = 1:length(windowFFT)
        if point*frequencyPerPoint > minBPM
            minPoint = point+1;
            break
        end
    end

    for point = 1:length(windowFFT)
        if point*frequencyPerPoint > maxBPM
            maxPoint = point;
            break
        end
    end
    windowFFT = windowFFT(minPoint:maxPoint)

    for index = 1:length(windowFFT)
        if windowFFT(index) > highestPoint
            highestPoint = windowFFT(index);
            bpmPoint = index;
        end
    end

    fprintf('Higher point: %.d', bpmPoint)
    bpmPerPoint = (maxBPM*60 - minBPM*60)/length(windowFFT)
    bpm = bpmPerPoint*(bpmPoint)
    fprintf('\n\n\n')
    averageBPM = averageBPM + bpm;
end

bpmFinal = averageBPM/windowsNumber;
fprintf('Le BPM de ce signal est de : %.f' ,bpmFinal)
