% Step 1: Load the original audio signal (speech without echo)
[original_signal, Fs] = audioread('near_end_signal.wav');  % Replace with the actual file path
original_signal = original_signal(:, 1);  % Use only the first channel (mono)

% Step 2: Parameters for Adaptive Filter and Echo Generation
echo_delay = 0.3;       % Echo delay in seconds
echo_gain = 0.5;        % Gain of the echo
M = 128;                % Number of filter taps (adaptive filter length)
mu = 0.001;             % LMS step-size (learning rate)

% Step 3: Generate the Echo Signal (simulate a delayed and attenuated copy)
delay_samples = round(echo_delay * Fs);  % Convert delay to samples
echo_signal = [zeros(delay_samples, 1); 
original_signal(1:end-delay_samples)] * echo_gain;

% Step 4: Create the Near-End Signal (original signal + echo)
near_end_signal = original_signal + echo_signal;  % Signal with echo

% Step 5: Initialize the Adaptive Filter
w = zeros(M, 1);       % Initialize filter weights (M taps)
y = zeros(length(near_end_signal), 1);  % Adaptive filter output (echo estimate)
e = zeros(length(near_end_signal), 1);  % Error signal (echo-canceled signal)
x_buffer = zeros(M, 1); % Buffer for the adaptive filter input

% Step 6: Apply LMS Algorithm for Echo Cancellation
for n = M:length(near_end_signal)
    % Update buffer with new sample from the near-end signal
    x_buffer = [near_end_signal(n); x_buffer(1:M-1)];
    
    % Adaptive filter output (echo estimate)
    y(n) = w' * x_buffer;
    
    % Compute the error signal (difference between the near-end signal and the filter output)
    e(n) = near_end_signal(n) - y(n);
    
    % Update the filter weights using LMS algorithm
    w = w + mu * e(n) * x_buffer;
end

% Step 7: Plot Results (Optional)
t = (0:length(near_end_signal)-1) / Fs;  % Time vector for plotting

% Plot the signals
figure;
subplot(3, 1, 1);
plot(t, near_end_signal);
title('Near-End Signal (Speech + Echo)');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3, 1, 2);
plot(t, y);
title('Adaptive Filter Output (Echo Estimate)');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3, 1, 3);
plot(t, e);
title('Error Signal (Echo-Canceled Signal)');
xlabel('Time (s)');
ylabel('Amplitude');

% Step 9: Play the signal with echo (Near-End Signal)
disp('Playing the near-end signal (with echo)...');
sound(near_end_signal, Fs);
pause(length(near_end_signal) / Fs + 1);  % Wait for the near-end audio to finish

% Step 10: Play the echo-canceled audio after a brief pause
disp('Waiting before playing the echo-canceled signal...');
pause(1);  % Wait for 3 seconds

disp('Playing the echo-canceled signal...');
sound(original_signal, Fs);
pause(length(original_signal) / Fs - 1);  % Play the error signal (echo-canceled audio)

% Step 11: Save the echo-canceled signal to a new audio file
output_file = 'echo_canceled_output.wav';  % Specify the output file name
audiowrite(output_file, e, Fs);
disp(['The echo-canceled signal has been saved as "' output_file '".']);

% Step 12: Optional - Plot frequency spectrum of both signals for comparison
figure;
subplot(2,1,1);
% Frequency spectrum of the near-end signal (with echo)
f_near_end = fft(near_end_signal);
f_near_end = abs(f_near_end(1:length(near_end_signal)/2));  % Frequency spectrum (magnitude)
frequencies = linspace(0, Fs/2, length(f_near_end));
plot(frequencies, f_near_end);
title('Frequency Spectrum of Near-End Signal (Speech + Echo)');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

subplot(2,1,2);
% Frequency spectrum of the echo-canceled signal
f_echo_canceled = fft(e);
f_echo_canceled = abs(f_echo_canceled(1:length(e)/2));  % Frequency spectrum (magnitude)
plot(frequencies, f_echo_canceled);
title('Frequency Spectrum of Echo-Canceled Signal');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
