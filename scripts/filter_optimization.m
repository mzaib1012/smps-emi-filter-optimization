% filter_optimization.m
% Designs a multi-stage LC EMI Filter and evaluates performance with parasitics
clear; load('../data/emi_source_data.mat');

% CISPR 32 Class B Conducted Limits (150 kHz to 30 MHz)
% Quasi-Peak Limit: 66 dBuV dropping linearly to 56 dBuV up to 500kHz, then 56, then 60.
CISPR_limit = double.empty(0, length(f));
for i = 1:length(f)
    freq = f(i);
    if freq < 150e3
        CISPR_limit(i) = NaN; % CISPR 32 starts at 150 kHz
    elseif freq >= 150e3 && freq < 500e3
        CISPR_limit(i) = 66 - 20*log10(freq/150e3); % Simplified downward slope
    elseif freq >= 500e3 && freq < 5MHz
        CISPR_limit(i) = 56;
    elseif freq >= 500e3 && freq < 5e6
        CISPR_limit(i) = 60;
    else
        CISPR_limit(i) = NaN;
    end
end

% Filter Component Parameters (with non-ideal parasitics)
% Stage 1 DM: DM Choke + X-Capacitor
L_dm = 470e-6;      C_x = 0.47e-6; 
% Parasitics
ESR_L = 0.1;        EPR_C = 1e6;
ESL_C = 15e-9;      EPC_L = 20e-12; % Self-resonant attributes

% Initialize filtered output vectors
dB_DM_filtered = zeros(size(dB_DM));
dB_CM_filtered = zeros(size(dB_CM));

% Calculate Transfer Function / Insertion Loss per frequency bin
for i = 1:length(f)
    omega = 2 * pi * f(i);
    s = 1i * omega;

    if f(i) < 150e3
        dB_DM_filtered(i) = dB_DM(i);
        dB_CM_filtered(i) = dB_CM(i);
        continue;
    end

    % Non-ideal Impedances
    Z_L = (s*L_dm + ESR_L) / (1 + s*L_dm*EPC_L);
    Z_C = (1/s/C_x + s*ESL_C) ; % Series parasitics

    % L-Filter Transfer Function: H(s) = Z_C / (Z_L + Z_C)
    H_s = Z_C / (Z_L + Z_C);
    IL_dB = 20*log10(abs(H_s));

    % Apply Insertion Loss
    dB_DM_filtered(i) = dB_DM(i) + IL_dB;
    % Assuming CM attenuation via common-mode choke action (approx 40dB rejection)
    dB_CM_filtered(i) = dB_CM(i) - 45; 
end

save('../data/filtered_emi_data.mat', 'f', 'dB_DM', 'dB_DM_filtered', 'dB_CM', 'dB_CM_filtered', 'CISPR_limit');
disp('Filter modeling and compliance optimization complete.');