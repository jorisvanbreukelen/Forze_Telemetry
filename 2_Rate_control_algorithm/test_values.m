clear all;

% Plotting paramets
number_of_simulations_per_value = 5;
min_probe_packet_modulus = 2;
number_of_probe_packet_modulus = 7;
min_mean_SNR = 10;
number_of_mean_SNR = 10;
mean_SNR_step_size = 2;

%Initializing matrices
mean_troughput_matrix = zeros(number_of_mean_SNR,number_of_probe_packet_modulus);
mean_packet_rate_matrix = zeros(number_of_mean_SNR,number_of_probe_packet_modulus);
min_troughput_matrix = zeros(number_of_mean_SNR,number_of_probe_packet_modulus);
min_packet_rate_matrix = zeros(number_of_mean_SNR,number_of_probe_packet_modulus);
max_troughput_matrix = zeros(number_of_mean_SNR,number_of_probe_packet_modulus);
meax_packet_rate_matrix = zeros(number_of_mean_SNR,number_of_probe_packet_modulus);

for k = 1:number_of_probe_packet_modulus
    probe_packet_modulus = k+min_probe_packet_modulus-1; 
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
        
        min_troughput_matrix(j,k) = min_troughput;
        min_packet_rate_matrix(j,k) = min_packet_error;
        
        max_troughput_matrix(j,k) = max_troughput;
        max_packet_rate_matrix(j,k) = max_packet_error;
   
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
MeanSNR_legend = min_mean_SNR:mean_SNR_step_size:mean_SNR_step_size*(number_of_mean_SNR-1)+min_mean_SNR; 

%2D plot
for i = 1:number_of_mean_SNR
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
