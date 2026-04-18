function temp_prediction(a)

% The function reads the analogue voltage from the temperature sensor,
% converts it into temperature, estimates the temperature rate of change
% from recent samples using linear regression, and predicts the temperature
% after 5 minutes assuming a constant rate of change. According to the
% measured condition, LEDs are used as warning indicators: green for stable
% comfort conditions, red for rapidly increasing temperature, and yellow
% for rapidly decreasing temperature. The program runs continuously until
% stopped manually by the user.

% Sensor parameters
TC  = 0.01;   % Temperature coefficient in V/deg C
V0  = 0.5;    % Output voltage at 0 deg C (V)

% Pin definition
greenPin  = 'D13';   % Green LED  - stable comfort range
redPin    = 'D12';   % Red LED    - temperature rising too fast
yellowPin = 'D8';    % Yellow LED - temperature falling too fast
sensorPin = 'A0';

% Threshold definition
T_low  = 18;          % Lower comfort bound (deg C)
T_high = 24;          % Upper comfort bound (deg C)
rateThresh = 4 / 60;  % 4 deg C/min converted to deg C/s

% Use a rolling window of samples for linear regression to estimate
% the derivative - this reduces the effect of short-term noise spikes
smoothWindow = 10;    % Number of samples used for derivative calculation

% Initialize the arrays and the LED lights
temps = [];   % Array to store temperature readings
times = [];   % Array to store corresponding timestamps

writeDigitalPin(a, greenPin,  0);
writeDigitalPin(a, redPin,    0);
writeDigitalPin(a, yellowPin, 0);

fprintf('  Temperature Prediction System - Started\n');

startTime = tic;  % Start timing

% For loop
while true

    % Read voltage
    voltage = readVoltage(a, sensorPin);

    % Convert voltage to temperature
    temp = (voltage - V0) / TC;

    % Record time and temperature
    elapsed = toc(startTime);
    temps(end+1) = temp;
    times(end+1) = elapsed;

    % Calculate the rate of chage for temperature
    if length(temps) >= smoothWindow
        % Use a rolling window - size is min of smoothWindow or available samples
        winSize = min(smoothWindow, length(temps));

        % Extract the window of recent samples
        t_win = times(end - winSize + 1 : end);
        T_win = temps(end - winSize + 1 : end);

        % Fit a linear polynomial to the window
        % p(1) is the slope = rate of change in deg C/s
        p    = polyfit(t_win, T_win, 1);
        rate = p(1);   % deg C/s
    else
        % Not enough data yet - assume zero rate of change
        rate = 0;
    end

    % Predict temperature in 5 mins
    % Assuming constant rate of change over 300 seconds
    T_predicted = temp + rate * 300;

    % print the current status
    fprintf('Time: %6.1f s | Temp: %6.2f C | Rate: %+.4f C/s (%+.2f C/min) | Predicted (5 min): %.2f C\n', ...
        elapsed, temp, rate, rate * 60, T_predicted);

    % LED control based on the rate of change
    % First turn off all LEDs, then apply the correct indicator
    writeDigitalPin(a, greenPin,  0);
    writeDigitalPin(a, redPin,    0);
    writeDigitalPin(a, yellowPin, 0);

    if rate > rateThresh
        % Temperature rising faster than +4 deg C/min, RED constant light
        fprintf('-----WARNING: Temperature rising rapidly!-----\n');
        writeDigitalPin(a, redPin, 1);

    elseif rate < -rateThresh
        % Temperature falling faster than -4 deg C/min, YELLOW constant light
        fprintf('-----WARNING: Temperature falling rapidly!-----\n');
        writeDigitalPin(a, yellowPin, 1);

    elseif temp >= T_low && temp <= T_high
        % Rate is within safe limits and within comfort range, GREEN constant light
        writeDigitalPin(a, greenPin, 1);

    end

    % wait 1 second before next reading
    pause(1);

end
end