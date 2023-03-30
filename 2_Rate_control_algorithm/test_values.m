clear all;

% Plotting paramets
number_of_simulations_per_value = 5;
min_probe_packet_modulus = 2;
number_of_probe_packet_modulus = 7;
number_of_max_jump = 5;
min_max_jump = 0.5;
max_jump_step_size = 1;
min_mean_SNR = 10;
number_of_mean_SNR = 10;
mean_SNR_step_size = 2;
min_amplitude = 1;
amplitude_step_size = 3;
number_of_amplitude = 10;

%Initializing matrices
mean_troughput_matrix = zeros(number_of_mean_SNR,number_of_amplitude);
mean_packet_rate_matrix = zeros(number_of_mean_SNR,number_of_amplitude);
min_troughput_matrix = zeros(number_of_mean_SNR,number_of_amplitude);
min_packet_rate_matrix = zeros(number_of_mean_SNR,number_of_amplitude);
max_troughput_matrix = zeros(number_of_mean_SNR,number_of_amplitude);
max_packet_rate_matrix = zeros(number_of_mean_SNR,number_of_amplitude);
mean_ber_matrix = zeros(number_of_mean_SNR,number_of_amplitude);
min_ber_matrix = zeros(number_of_mean_SNR,number_of_amplitude);
max_ber_matrix = zeros(number_of_mean_SNR,number_of_amplitude);

ber_iterations = zeros(1,number_of_simulations_per_value);

for k = 1:number_of_amplitude
    amplitude = amplitude_step_size * k+min_amplitude - amplitude_step_size;
%     maxJump = max_jump_step_size * k + min_max_jump - max_jump_step_size;
    for j = 1:number_of_mean_SNR
        meanSNR = mean_SNR_step_size*(j-1)+min_mean_SNR;
        s = rng(21);
        min_troughput = inf;
        max_troughput = 0;
        accumulated_troughput = 0;
        mean_troughput = 0;

        min_packet_error = 1;
        max_packet_error = 0;
        accumulated_packet_error = 0;
        mean_packet_error = 0;
        
        for i = 1:number_of_simulations_per_value
            
            close all;
            execute_all_rate_control_algorithms

            ov_dr = str2num(ov_dr);
            ov_per = str2num(ov_per);
            accumulated_troughput = accumulated_troughput + ov_dr;
            accumulated_packet_error = accumulated_packet_error + ov_per;
            ber_iterations(1,i) = mean(ber);
            
            %Determine min and max values
            if ov_dr > max_troughput
                max_troughput = ov_dr;
            end
            
            if ov_dr < min_troughput
                min_troughput = ov_dr;
            end
            
            if ov_per > max_packet_error
                max_packet_error = ov_per;
            end
            
            if ov_per < min_packet_error
                min_packet_error = ov_per;
            end
            
        end
        mean_troughput = accumulated_troughput/number_of_simulations_per_value;
        mean_packet_error = accumulated_packet_error/number_of_simulations_per_value;
        
        mean_troughput_matrix(j,k) = mean_troughput;
        mean_packet_rate_matrix(j,k) = mean_packet_error;
        mean_ber_matrix(j,k) = mean(ber_iterations);
        
        min_troughput_matrix(j,k) = min_troughput;
        min_packet_rate_matrix(j,k) = min_packet_error;
        min_ber_matrix(j,k) = min(ber_iterations);
        
        max_troughput_matrix(j,k) = max_troughput;
        max_packet_rate_matrix(j,k) = max_packet_error;
        max_ber_matrix(j,k) = max(ber_iterations);
   
    end
end

disp(['Mean data rate: ' num2str(mean_troughput) ' Mbps']);
disp(['Max data rate: ' num2str(max_troughput) ' Mbps']);
disp(['Min data rate: ' num2str(min_troughput) ' Mbps']);
disp(['Mean packet error: ' num2str(mean_packet_error)]);
disp(['Max packet error: ' num2str(max_packet_error)]);
disp(['Min packet error: ' num2str(min_packet_error)]);

close all;
