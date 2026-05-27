% compliance_plotter.m
% Visualizes raw vs filtered emissions against CISPR 32 standards
clear; load('../data/filtered_emi_data.mat');

figure('Position', [100, 100, 900, 550]);

% Target Conducted Emissions Band
idx = find(f >= 150e3 & f <= 30e6);

subplot(2,1,1);
semilogx(f(idx)/1e6, dB_DM(idx), 'r--', 'LineWidth', 1); hold on;
semilogx(f(idx)/1e6, dB_DM_filtered(idx), 'b-', 'LineWidth', 1.5);
semilogx(f(idx)/1e6, CISPR_limit(idx), 'k-', 'LineWidth', 2);
grid on; xlim([0.15, 30]); ylim([0, 120]);
title('Differential Mode (DM) Conducted Emissions Profile');
xlabel('Frequency (MHz)'); ylabel('Amplitude (dB\muV)');
legend('Unfiltered Noise', 'Optimized LC Filtered', 'CISPR 32 Class B Limit');

subplot(2,1,2);
semilogx(f(idx)/1e6, dB_CM(idx), 'r--', 'LineWidth', 1); hold on;
semilogx(f(idx)/1e6, dB_CM_filtered(idx), 'b-', 'LineWidth', 1.5);
semilogx(f(idx)/1e6, CISPR_limit(idx), 'k-', 'LineWidth', 2);
grid on; xlim([0.15, 30]); ylim([0, 120]);
title('Common Mode (CM) Conducted Emissions Profile');
xlabel('Frequency (MHz)'); ylabel('Amplitude (dB\muV)');
legend('Unfiltered Noise', 'Optimized CM Filtered', 'CISPR 32 Class B Limit');

% Save profile figure for GitHub Readme showcase
saveas(gcf, '../data/compliance_verification.png');
disp('Compliance visualization graphic rendered successfully.');