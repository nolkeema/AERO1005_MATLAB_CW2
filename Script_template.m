% Shenteng MA
% ssysm5@nottingham.edu.cn


%% PRELIMINARY TASK - ARDUINO AND GIT INSTALLATION [5 MARKS]

clc;
clear;
close all;
a = arduino('/dev/cu.usbserial-120','Uno');

for n = 1:10
    writeDigitalPin(a, 'D12', 1);
    pause(0.5);
    writeDigitalPin(a, 'D12', 0);
    pause(0.5);
end
disp('Program Finished')

%% TASK 1 - READ TEMPERATURE DATA, PLOT, AND WRITE TO A LOG FILE [20 MARKS]

clc;
clear;
close all;
a = arduino('/dev/cu.usbserial-120','Uno');

% create the array to store the data
duration = 600;
timeData = zeros(duration+1,1);
voltageData = zeros(duration+1,1);
tempData = zeros(duration+1,1);

for i = 1:duration+1
    timeData(i) = i-1;
    voltageData(i) = readVoltage(a, 'A0');
    tempData(i) = (voltageData(i) - 0.5) * 100;
    fprintf('Time = %d, Temperature = %.2f\n', timeData(i), tempData(i));

    pause(1);
end

disp('Data logging completed');

% analyze the data
maxTemp = max(tempData);
minTemp = min(tempData);
avgTemp = mean(tempData);


fprintf('The maximum temperature is: %.2f\n', maxTemp);
fprintf('The minimum temperature is: %.2f\n', minTemp);
fprintf('The average temperature is: %.2f\n', avgTemp);

% generate the graph of collected data
figure;
plot(timeData, tempData, 'LineWidth', 1.5);
title('Time - Temperature Graph');
xlabel('Time (s)');
ylabel('Temperature (degC)');
grid on;

saveas(gcf,'task1_temperature_plot.png');

logText = sprintf('Data logging initiated - %s\n', datestr(now));
logText = [logText, sprintf('Location - Capsule\n')];

maxMinute = floor((length(tempData) - 1) / 60);

for m = 0:maxMinute
    idx = m * 60 + 1;
    logText = [logText, sprintf('Minute %d\t%.2f degC\n', m, tempData(idx))];
end

logText = [logText, sprintf('Max temp\t%.2f degC\n', maxTemp)];
logText = [logText, sprintf('Min temp\t%.2f degC\n', minTemp)];
logText = [logText, sprintf('Average temp\t%.2f degC\n', avgTemp)];
logText = [logText, sprintf('Data logging terminated\n')];

% Display log in Command Window
disp(logText);

% Write log to text file
fid = fopen('capsule_temperature.txt', 'w');
fprintf(fid, '%s', logText);
fclose(fid);
%% TASK 2 - LED TEMPERATURE MONITORING DEVICE IMPLEMENTATION [25 MARKS]

% Insert answers here


%% TASK 3 - ALGORITHMS – TEMPERATURE PREDICTION [30 MARKS]

% Insert answers here


%% TASK 4 - REFLECTIVE STATEMENT [5 MARKS]

% Insert answers here