clear all;

%To run this script correctly, comment out:
% maxJump in execute_all_rate_control_algorithms.m (line 117)
% enable_fast_decrease in algo2.m (line 21)
% s = rng(21); in algo2.m (line 15)
% rng(s); in algo2.m (line 140) 

% Plotting paramets
number_of_simulations_per_value = 1; %5
min_max_jump = 18; %10
number_of_max_jump = 50; %10
max_jump_step_size = 0.1;

%Initializing matrices
mean_troughput_matrix = zeros(number_of_max_jump,2);
mean_packet_rate_matrix = zeros(number_of_max_jump,2);
min_troughput_matrix = zeros(number_of_max_jump,2);
min_packet_rate_matrix = zeros(number_of_max_jump,2);
max_troughput_matrix = zeros(number_of_max_jump,2);
max_packet_rate_matrix = zeros(number_of_max_jump,2);
mean_ber_matrix = zeros(number_of_max_jump,2);
min_ber_matrix = zeros(number_of_max_jump,2);
max_ber_matrix = zeros(number_of_max_jump,2);

ber_iterations = zeros(1,number_of_simulations_per_value);

for k = 1:2
    enable_fast_decrease = k-1; %true or false
    for j = 1:number_of_max_jump
        meanSNR = max_jump_step_size*(j-1)+min_max_jump;
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

%Create legends for plotting
probe_packet_modulus_legend = min_probe_packet_modulus:min_probe_packet_modulus+number_of_probe_packet_modulus-1; 
MeanSNR_legend = min_max_jump:max_jump_step_size:max_jump_step_size*(number_of_max_jump-1)+min_max_jump; 

%2D plot
for i = 1:number_of_max_jump
    %Create confidence intervals with min and max values
    xconf = [probe_packet_modulus_legend probe_packet_modulus_legend(end:-1:1)] ;         
    yconf = [max_troughput_matrix(i,1:end) min_troughput_matrix(i,end:-1:1)];
    
    %Plot confidence intervals red
    p = fill(xconf,yconf,'red');
    hold on;
    p.FaceColor = [1 0.8 0.8];      
    p.EdgeColor = 'none';
    
    xlabel('Probe packet modulus')
    ylabel('Troughput [Mbps]')
    legend(num2str(i))
    plot(probe_packet_modulus_legend,mean_troughput_matrix(i,1:end))
end


%3D plot
% hold on;
% surf(probe_packet_modulus_legend,MeanSNR_legend,mean_troughput_matrix)
% surf(probe_packet_modulus_legend,MeanSNR_legend,mean_packet_rate_matrix)
