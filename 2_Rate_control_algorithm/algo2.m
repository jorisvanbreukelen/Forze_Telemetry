%% 802.11 Dynamic Rate Control Simulation
%
% This example shows dynamic rate control by varying the Modulation and
% Coding scheme (MCS) of successive packets transmitted over a frequency
% selective multipath fading channel.

% Example adapted to serve as an input to the final project assignment
% "Rate control Algorithm" for TU Delft ET4394 Course 2020 edition.

% Copyright 2016-2019 The MathWorks, Inc.
% Additions specific to ET4394 2020 Course at TU Delft: 2020 Przemysław
% Pawełczak

% Set random stream for repeatability of results
% s = rng(21); % It will be restored later as rng(s)

%% Rate Control Algorithm Parameters
errorSNR_offset = 2; % SNR needs to be higher than errorSNR + offset to start probing
probe_startup = true; % Enable startup probing.
% probe_packet_modulus = 6; % Probe higher bit rate every X packets.
enable_fast_decrease = true;

%% Define simulation variables

snrMeasured = zeros(1,numPackets);
MCS = zeros(1,numPackets);
ber = zeros(1,numPackets);
packetLength = zeros(1,numPackets);

errorSNR = -Inf(1, 10);
probe_now = false;
last_packet_failed = false;

%% Processing Chain

for numPkt = 1:numPackets
    %%%% RATE CONTROL ALGORITHM %%%%
    % Probe higher bit rates.
    % Done on startup until a bit error occurs.
    % Done every 'probe_packet_modulus' packets.
    % Can be blocked by SNR not being high enough -> probe directly when SNR is high enough.
    send_probe = false; % Indicates when we probe.

    if (mod(numPkt, probe_packet_modulus) == 0 || probe_now || probe_startup) && cfgVHT.MCS <= 8
        % Select correct index for snrMeasured.
        pkt_index = numPkt - 1;
        if numPkt == 1
            pkt_index = 1;
        end

        % If the SNR is higher than previously measured SNR at which bit
        % error occurred, plus a defined offset, only then probe higher bit
        % rate.
        if ~isnan(snrMeasured(pkt_index)) && snrMeasured(pkt_index) > errorSNR(cfgVHT.MCS + 2) + errorSNR_offset
            send_probe = true;
            cfgVHT.MCS = cfgVHT.MCS + 1;
            probe_now = false;
        else
            % If the SNR is not high enough, postpone probe until it is.
            probe_now = true;
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    snrWalk = 0.9 * snrWalk + 0.1 * baseSNR(numPkt) + rand(1) * maxJump * 2 - maxJump; % DO NOT CHANGE THIS % Generate SNR value per packet using random walk algorithm biased towards the mean SNR

    txPSDU = randi([0,1],8 * cfgVHT.PSDULength, 1, 'int8');        % DO NOT CHANGE THIS % randomly generate bits of cfgVHT.PSDULength length
    txWave = wlanWaveformGenerator(txPSDU,cfgVHT,'IdleTime',5e-4); % DO NOT CHANGE THIS % randomly generate a single packet waveform
    
    y = processPacket(txWave,snrWalk,tgacChannel,cfgVHT);          % DO NOT CHANGE THIS % Receive processing, including SNR estimation
    
    % Store estimated SNR value for each packet
    if isempty(y.EstimatedSNR) 
        snrMeasured(1,numPkt) = 0;
    else
        snrMeasured(1,numPkt) = y.EstimatedSNR;
        %snrMeasured(1,numPkt) = snrWalk;
    end
    
    % Determine the length of the packet in seconds including idle time
    packetLength(numPkt) = y.RxWaveformLength/sr;
    
    % Calculate packet error rate (PER)
    if isempty(y.RxPSDU)
        % Set the PER of an undetected packet to NaN
        ber(numPkt) = NaN;
    else
        [~,ber(numPkt)] = biterr(y.RxPSDU,txPSDU);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%% RATE CONTROL ALGORITHM %%%%
    % Packet failed when bit error rate is larger than 0.
    packet_failed = isnan(ber(numPkt)) || ber(numPkt) > 0;

    % Save MCS into array.
    MCS(numPkt) = cfgVHT.MCS;
    
    if packet_failed
        % Terminate startup procedure.
        probe_startup = false;

        % Set SNR ar which error occurred for selected MCS.
        errorSNR(1,cfgVHT.MCS + 1) = snrMeasured(1,numPkt);
       
        if cfgVHT.MCS > 0
            % Decrease MCS by 2 if two successive non-probe packets failed.

            if last_packet_failed && ~send_probe && enable_fast_decrease
                if cfgVHT.MCS >= 2
                    cfgVHT.MCS = cfgVHT.MCS - 2;
                else
                    cfgVHT.MCS = 0;
                end
            % If only one packet failed, decrease MCS.
            else
                cfgVHT.MCS = cfgVHT.MCS - 1;
            end
        end
        
    end
    
    % Set last_packet_failed if it is not a probe packet.
    if ~send_probe
        last_packet_failed = packet_failed;
    end
end

%% Display and Plot Simulation Results

% Display and plot simulation results
ov_dr = num2str(8*cfgVHT.APEPLength*(numPackets-numel(find(ber)))/sum(packetLength)/1e6);
disp(['Overall data rate: ' ov_dr ' Mbps']);
ov_per = num2str(numel(find(ber))/numPackets);
disp(['Overall packet error rate: ' ov_per]);

plotResults(ber,packetLength,snrMeasured,MCS,cfgVHT);

% Restore default stream
% rng(s);

% NOTE: TRY NOT TO CHANGE THIS FUNCTION - let us make the packet processing the same for everyone
function Y = processPacket(txWave,snrWalk,tgacChannel,cfgVHT)
    % Pass the transmitted waveform through the channel, perform
    % receiver processing, and SNR estimation.
    
    chanBW = cfgVHT.ChannelBandwidth; % Channel bandwidth
    % Set the following parameters to empty for an undetected packet
    estimatedSNR = [];
    eqDataSym = [];
    noiseVarVHT = [];
    rxPSDU = [];
    
    ofdmInfo = wlanVHTOFDMInfo('VHT-Data',cfgVHT); % Get the OFDM info
    rxWave = tgacChannel(txWave); % Pass the waveform through the fading channel model
   
    awgnChannel = comm.AWGNChannel; % Create an instance of the AWGN channel for each transmitted packet
    awgnChannel.NoiseMethod = 'Signal to noise ratio (SNR)';
    awgnChannel.SignalPower = 1/tgacChannel.NumReceiveAntennas; % Normalization
    awgnChannel.SNR = snrWalk - 10 * log10(ofdmInfo.FFTLength/ofdmInfo.NumTones); % Account for energy in nulls
    
    rxWave = awgnChannel(rxWave); % Add noise
    rxWaveformLength = size(rxWave,1); % Length of the received waveform
    
    % Recover packet
    ind = wlanFieldIndices(cfgVHT); % Get field indices
    pktOffset = wlanPacketDetect(rxWave,chanBW); % Detect packet
    
    if ~isempty(pktOffset) % If packet detected
        LLTFSearchBuffer = rxWave(pktOffset+(ind.LSTF(1):ind.LSIG(2)),:); % Extract the L-LTF field for fine timing synchronization
        finePktOffset = wlanSymbolTimingEstimate(LLTFSearchBuffer,chanBW); % Start index of L-LTF field
        pktOffset = pktOffset + finePktOffset; % Determine final packet offset
        
        if pktOffset < 15 % If synchronization successful
            % Extract VHT-LTF samples from the waveform, demodulate and perform channel estimation
            VHTLTF = rxWave(pktOffset + (ind.VHTLTF(1):ind.VHTLTF(2)),:);
            demodVHTLTF = wlanVHTLTFDemodulate(VHTLTF,cfgVHT);
            chanEstVHTLTF = wlanVHTLTFChannelEstimate(demodVHTLTF,cfgVHT);
            chanEstSSPilots = vhtSingleStreamChannelEstimate(demodVHTLTF,cfgVHT); % Get single stream channel estimate
            vhtdata = rxWave(pktOffset+(ind.VHTData(1):ind.VHTData(2)),:); % Extract VHT data field
            noiseVarVHT = vhtNoiseEstimate(vhtdata,chanEstSSPilots,cfgVHT); % Estimate the noise power in VHT data field
            
            % Recover equalized symbols at data carrying subcarriers using channel estimates from VHT-LTF
            [rxPSDU,~,eqDataSym] = wlanVHTDataRecover(vhtdata,chanEstVHTLTF,noiseVarVHT,cfgVHT);
            
            % SNR estimation per receive antenna
            powVHTLTF = mean(VHTLTF.*conj(VHTLTF));
            estSigPower = powVHTLTF - noiseVarVHT;
            estimatedSNR = 10*log10(mean(estSigPower./noiseVarVHT));
        end
    end
    
    % Set output
    Y = struct( ...
        'RxPSDU',           rxPSDU, ...
        'EqDataSym',        eqDataSym, ...
        'RxWaveformLength', rxWaveformLength, ...
        'NoiseVar',         noiseVarVHT, ...
        'EstimatedSNR',     estimatedSNR);
    
end

function plotResults(ber,packetLength,snrMeasured,MCS,cfgVHT)
    % Visualize simulation results

    figure('Outerposition',[50 50 900 700])
    subplot(4,1,1);
    plot(MCS);
    xlabel('Packet Number')
    ylabel('MCS')
    title('MCS selected for transmission')

    subplot(4,1,2);
    plot(snrMeasured);
    xlabel('Packet Number')
    ylabel('SNR')
    title('Estimated SNR')

    subplot(4,1,3);
    plot(find(ber==0),ber(ber==0),'x') 
    hold on; stem(find(ber>0),ber(ber>0),'or') 
    if any(ber)
        legend('Successful decode','Unsuccessful decode') 
    else
        legend('Successful decode') 
    end
    xlabel('Packet Number')
    ylabel('BER')
    title('Instantaneous bit error rate per packet')

    subplot(4,1,4);
    windowLength = 3; % Length of the averaging window
    movDataRate = movsum(8*cfgVHT.APEPLength.*(ber==0),windowLength)./movsum(packetLength,windowLength)/1e6;
    plot(movDataRate)
    xlabel('Packet Number')
    ylabel('Mbps')
    title(sprintf('Throughput over last %d packets',windowLength))
    
end
