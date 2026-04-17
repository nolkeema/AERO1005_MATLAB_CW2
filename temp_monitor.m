function temp_monitor(a)
% green for 18-24 C, yellow blinking below 18 C, and red blinking above
% 24 C. The function runs continuously until manually stopped.

    % Pin definitions
    sensorPin = 'A0';
    yellowPin = 'D8';
    redPin = 'D12';
    greenPin = 'D13';

    % Sensor constants for MCP9700A
    V0 = 0.5;      % Voltage at 0 degC
    TC = 0.01;     % Temperature coefficient, V/degC

    % Data storage
    timeData = [];
    tempData = [];

    % Initialise figure
    figure;
    h = plot(NaN, NaN, '-o');
    xlabel('Time (s)');
    ylabel('Temperature (^oC)');
    title('Live Temperature Monitoring');
    grid on;

    tStart = tic;
try
    while true
        % Time
        tNow = toc(tStart);

        % Read voltage and convert to temperature
        voltage = readVoltage(a, sensorPin);
        temp = (voltage - V0) / TC;

        % Store data
        timeData(end+1) = tNow;
        tempData(end+1) = temp;

        % Update live plot
        set(h, 'XData', timeData, 'YData', tempData);
        xlim([max(0,tNow-60), tNow+5]);
        ylim([min(tempData)-2, max(tempData)+2]);
        drawnow;

        % LED logic
        if temp >= 18 && temp <= 24
            writeDigitalPin(a, greenPin, 1);    % green light on
            writeDigitalPin(a, yellowPin, 0);   % yellow light off
            writeDigitalPin(a, redPin, 0);      % red light off
            pause(1);

        elseif temp < 18
            writeDigitalPin(a, greenPin, 0);
            writeDigitalPin(a, redPin, 0);

            writeDigitalPin(a, yellowPin, 1);     % yellow on
            pause(0.5);
            writeDigitalPin(a, yellowPin, 0);
            pause(0.5);

        else
            writeDigitalPin(a, greenPin, 0);
            writeDigitalPin(a, yellowPin, 0);

            for blink = 1:2
                writeDigitalPin(a, redPin, 1);    % red on
                pause(0.25);
                writeDigitalPin(a, redPin, 0);
                pause(0.25);
            end
        end
    end
catch
    writeDigitalPin(a, yellowPin, 0);
    writeDigitalPin(a, greenPin, 0);
    writeDigitalPin(a, redPin, 0);
end
end
