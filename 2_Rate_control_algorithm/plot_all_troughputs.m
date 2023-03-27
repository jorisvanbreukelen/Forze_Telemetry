%2D plot

%Create legends for plotting
probe_packet_modulus_legend = min_probe_packet_modulus:min_probe_packet_modulus+number_of_probe_packet_modulus-1; 
MeanSNR_legend = min_mean_SNR:mean_SNR_step_size:mean_SNR_step_size*(number_of_mean_SNR-1)+min_mean_SNR; 

C = colororder;
for i = 3:number_of_mean_SNR-3
    %Create confidence intervals with min and max values
    xconf = [probe_packet_modulus_legend probe_packet_modulus_legend(end:-1:1)] ;         
    yconf = [max_troughput_matrix(i,1:end) min_troughput_matrix(i,end:-1:1)];
    
    %Plot confidence intervals red
    p = fill(xconf,yconf,C(i-2,:),'FaceAlpha',.3);
    hold on;
    p.FaceColor = C(i,:);      
    p.EdgeColor = 'none';
    
    xlabel('Probe packet modulus')
    ylabel('Troughput [Mbps]')
    legend(num2str(i))
    plot(probe_packet_modulus_legend,mean_troughput_matrix(i,1:end),'k')
end