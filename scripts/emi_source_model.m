% emi_source_model.m
% Models the SMPS high-frequency switching noise source (Trapezoidal Wave)
clear; clc;

% Simulation Parameters
Fs = 50e6;                  % Sampling frequency (50 MHz to cover 150kHz - 30MHz band)
dt = 1/Fs;
t = 0:dt:2e-4;              % 200 us time window
N = length(t);

% SMPS Operating Parameters
Fsw = 100e3;                % Switching frequency: 100 kHz
Duty = 0.45;                % 45% Duty Cycle
V_in = 400;                 % DC Bus Voltage (V)
Rise_time = 50e-9;          % 50 ns rise time (high dV/dt source of noise)
Fall_time = 50e-9;          % 50 ns fall time

% Generate Ideal Trapezoidal Switching Waveform
Tsw = 1/Fsw;
t_mod = mod(t, Tsw);
V_sw = zeros(size(t));

for i = 1:length(t)
    tm = t_mod(i);
    if tm < Rise_time
        V_sw(i) = V_in * (tm / Rise_time);
    elseif tm < Duty*Tsw
        V_sw(i) = V_in;
    elseif tm < (Duty*Tsw + Fall_time)
        V_sw(i) = V_in - V_in * ((tm - Duty*Tsw) / Fall_time);
    else
        V_sw(i) = 0;
    end
end

% Extract DM and CM Noise Voltages (Simplified Parasitic Coupling)
% DM noise correlates with input current ripples; CM noise correlates with dV/dt through parasitic Cp
Cp_stray = 150e-12;         % 150 pF stray capacitance to chassis
R_lisn = 50;                % Standard 50 Ohm LISN resistor

V_DM = V_sw * 0.05;         % DM noise voltage approximation from current ripple
V_CM = [0, diff(V_sw)/dt] * Cp_stray * R_lisn; % CM noise via dV/dt coupling
V_CM(end+1) = V_CM(end);    % Keep vector dimensions equal

% Frequency Domain Analysis via FFT
f = (0:N/2-1)*(Fs/N);
FFT_DM = fft(V_DM)/N;
FFT_CM = fft(V_CM)/N;

% Convert to dBuV (Standard EMI Unit)
num_elements = floor(N/2);
dB_DM = 20*log10(abs(FFT_DM(1:num_elements))*2 / 1e-6);
dB_CM = 20*log10(abs(FFT_CM(1:num_elements))*2 / 1e-6);

% Save processed spectrum data for filter script
save('../data/emi_source_data.mat', 'f', 'dB_DM', 'dB_CM');
disp('EMI Source Spectrum generated and saved successfully.');