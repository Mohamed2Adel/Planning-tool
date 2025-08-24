clc; clear; close all;
%%Part B1 

%% Parameters
n = 4;                                % Path loss exponent
SIR_dB = 1:0.1:30;                    % SIR range in dB (more precise)
SIR_linear = 10.^(SIR_dB/10);         % Convert SIR to linear scale

% Interference factors for sectorizations
i0_omni = 6;
i0_120 = 2;
i0_60 = 1;

%% Generate valid cluster sizes: N = i^2 + k^2 + i*k for i,k = 0..max_index, excluding (0,0)
max_index = 10;
N_values = [];

for i = 0:max_index
    for k = 0:max_index
        if i == 0 && k == 0
            continue;
        end
        N_tmp = i^2 + k^2 + i*k;
        N_values = [N_values, N_tmp];
    end
end

N_valid = unique(N_values);
N_valid = sort(N_valid);

%% Function to round cluster size up to next valid N
roundUpN = @(Nth) min(N_valid(N_valid >= Nth));

%% Part 1: Calculate cluster size for each SIR and sectorization type,
% rounding up to next valid cluster size

N_omni = zeros(size(SIR_linear));
N_120 = zeros(size(SIR_linear));
N_60 = zeros(size(SIR_linear));

for idx = 1:length(SIR_linear)
    SIR = SIR_linear(idx);
    
    % Theoretical continuous cluster size formula:
    N_th_omni = ( (SIR * i0_omni)^(1/n) + 1 )^2 / 3;
    N_th_120  = ( (SIR * i0_120 )^(1/n) + 1 )^2 / 3;
    N_th_60   = ( (SIR * i0_60  )^(1/n) + 1 )^2 / 3;
    
    % Round up to next valid cluster size from N_valid
    N_omni(idx) = roundUpN(N_th_omni);
    N_120(idx)  = roundUpN(N_th_120);
    N_60(idx)   = roundUpN(N_th_60);
end

%% Plot Cluster Size vs SIR
figure;
stairs(SIR_dB, N_omni, 'r', 'LineWidth', 2); hold on;
stairs(SIR_dB, N_120, 'g--', 'LineWidth', 2);
stairs(SIR_dB, N_60, 'b-.', 'LineWidth', 2);
grid on;
xlabel('Minimum SIR (dB)');
ylabel('Cluster Size (N)');
title('Cluster Size vs Minimum SIR with discrete valid cluster sizes');
legend('Omni-directional', '120° Sectorization', '60° Sectorization');