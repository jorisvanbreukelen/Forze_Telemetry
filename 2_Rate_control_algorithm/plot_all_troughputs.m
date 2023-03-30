%Create legends for plotting

%Uncomment which parameter you want to plot:
amplitude_legend = [1,4,7,10,13,16,19,22,25,28];
% maxjump_legend = [0.5, 1.5, 2.5, 3.5, 4.5];
% probe_packet_modulus_legend = min_probe_packet_modulus:min_probe_packet_modulus+number_of_probe_packet_modulus-1;
% error_SNR_offset_legend = min_error_SNR_offset:error_SNR_offset_step_size:min_error_SNR_offset+(number_of_error_SNR_offset-1)*error_SNR_offset_step_size; 
MeanSNR_legend = min_mean_SNR:mean_SNR_step_size:mean_SNR_step_size*(number_of_mean_SNR-1)+min_mean_SNR; 

plots=[];

%2D plot
C = colororder;
colorindex = 1;
for i = 1:10
    %Create confidence intervals with min and max values (Uncomment what you want to plot)
    % xconf = [maxjump_legend maxjump_legend(end:-1:1)] ;  
    xconf = [amplitude_legend amplitude_legend(end:-1:1)];
%     xconf = [probe_packet_modulus_legend probe_packet_modulus_legend(end:-1:1)];
%     xconf = [error_SNR_offset_legend error_SNR_offset_legend(end:-1:1)];

%     yconf = [max_troughput_matrix(i,1:end) min_troughput_matrix(i,end:-1:1)];
    yconf = [max_packet_rate_matrix(i,1:end) min_packet_rate_matrix(i,end:-1:1)];
    
    %Plot confidence intervals
    p = fill(xconf,yconf,C(colorindex,:),'FaceAlpha',.3);
    colorindex = colorindex + 1;
    if colorindex > 7
        colorindex = 1;
    end
    hold on;    
    p.EdgeColor = 'none';
    
    set(gca,'FontSize',24)
%     title("Throughput vs. SNR Max Jump for Matlab Template")
%     title("Packet error rate vs. error SNR offset for our algorithm")
%     title("Throughput vs. Probe Packet Modulus for our algorithm")
      title("Packet Error Rate vs. Amplitude for our Algorithm")
    
%     xlabel('SNR Max Jump')
    xlabel('SNR Amplitude')
%     xlabel('Error SNR offset')
%     xlabel('Probe Packet Modulus')

    ylabel('Packet Error Rate')
%     ylabel('Troughput [Mbps]')

    % Edit what parameter you want to plot:
    plt = plot(amplitude_legend,mean_packet_rate_matrix(i,1:end), 'DisplayName', "Mean SNR: " + MeanSNR_legend(i));
%     plt = plot(amplitude_legend,mean_troughput_matrix(i,1:end), 'DisplayName', "Mean SNR: " + MeanSNR_legend(i));
    p.FaceColor = plt.Color;
end

legend

%3D plot
% hold on;
% surf(probe_packet_modulus_legend,MeanSNR_legend,mean_troughput_matrix)
% surf(probe_packet_modulus_legend,MeanSNR_legend,mean_packet_rate_matrix)