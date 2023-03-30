%Create legends for plotting
%probe_packet_modulus_legend = min_probe_packet_modulus:min_probe_packet_modulus+number_of_probe_packet_modulus-1; 
%MeanSNR_legend = min_mean_SNR:mean_SNR_step_size:mean_SNR_step_size*(number_of_mean_SNR-1)+min_mean_SNR; 

% amplitude_legend = [1,4,7,10,13,16,19,22,25,28];
% maxjump_legend = [0.5, 1.5, 2.5, 3.5, 4.5];
max_jump_legend = min_max_jump:max_jump_step_size:min_max_jump+(number_of_max_jump-1)*max_jump_step_size;
% error_SNR_offset_legend = min_error_SNR_offset:error_SNR_offset_step_size:min_error_SNR_offset+(number_of_error_SNR_offset-1)*error_SNR_offset_step_size; 
% MeanSNR_legend = min_mean_SNR:mean_SNR_step_size:mean_SNR_step_size*(number_of_mean_SNR-1)+min_mean_SNR; 


plots=[];

%2D plot
C = colororder;
colorindex = 1;
for i = 1:2
    %Create confidence intervals with min and max values
    % xconf = [maxjump_legend maxjump_legend(end:-1:1)] ;  
%     xconf = [amplitude_legend amplitude_legend(end:-1:1)];
    xconf = [max_jump_legend max_jump_legend(end:-1:1)];
%     xconf = [error_SNR_offset_legend error_SNR_offset_legend(end:-1:1)];

%     yconf = [max_troughput_matrix(1:end,i)' min_troughput_matrix(end:-1:1,i)'];
    yconf = [max_packet_rate_matrix(1:end,i)' min_packet_rate_matrix(end:-1:1,i)'];
    
    %Plot confidence intervals red
    p = fill(xconf,yconf,C(colorindex,:),'FaceAlpha',.3);
    colorindex = colorindex + 1;
    if colorindex > 7
        colorindex = 1;
    end
    hold on;
%     p.FaceColor = C(i,:);      
    p.EdgeColor = 'none';
    
    set(gca,'FontSize',24)

    title("Packet error Rate vs. maxJump for our algorithm")  
%     xlabel('SNR Max Jump')
%     xlabel('SNR Amplitude')
%     xlabel('Error SNR offset')
    xlabel('maxJump')

    ylabel('Packet error rate')
%     ylabel('Troughput [Mbps]')
%     plt = plot(max_jump_legend,mean_packet_rate_matrix(1:end,i), 'DisplayName', "Mean SNR: " + MeanSNR_legend(i));
%     plt = plot(max_jump_legend,mean_troughput_matrix(1:end,i), 'DisplayName', "Mean SNR: " + MeanSNR_legend(i));
%     plt = plot(max_jump_legend,mean_troughput_matrix(1:end,i));
    plt = plot(max_jump_legend,mean_packet_rate_matrix(1:end,i));
    p.FaceColor = plt.Color;
end

legend


%3D plot
% hold on;
% surf(probe_packet_modulus_legend,MeanSNR_legend,mean_troughput_matrix)
% surf(probe_packet_modulus_legend,MeanSNR_legend,mean_packet_rate_matrix)