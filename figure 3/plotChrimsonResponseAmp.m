% plotChrimsonResponse
% paper analysis for stim chrimson experiments for R2 neurons and lookign at EPG responses
% Yvette Fisher 8/2018

%% Plot each IPSP from this trial and calculate average amplitude
close all;
ephysSettings;

FigHand = figure('Position',[50, 50, 1800, 800]);
set(gcf, 'Color', 'w');
set(gcf,'renderer','Painters')
set(gca,'TickDir','out'); % The only other option is 'in'


% check if scaled voltage exists
if(isfield(data,'scaledVoltage'))
    dataTrace = data.scaledVoltage; % for current clamp traces
else
    dataTrace = data.scaledCurrent;
end 

timeArray = (1  :  length(data.current) ) / settings.sampRate; % seconds

DURATION_TO_PLOT_BEFORE_FLASH = 1;
DURATION_TO_PLOT_PER_EPOCH = 4; % sec

EPOCH_TO_FIND_MINIMUM = 1;
EPOCH_TO_FIND_BASELINE = 1;

STEP_ONSET_MAGNITUDE = 0;
OFFSET_FOR_PLOT = 0;

stimChanges =  diff( stimulus.shutterCommand );
% find index where the shuttle value increases
epochStartInds = find( stimChanges > STEP_ONSET_MAGNITUDE);

traces = [];

preStimAve =[];
postStimMin = [];

for i = 1 : numel(epochStartInds) - 1    
    currEpochStart = epochStartInds(i) - ( DURATION_TO_PLOT_BEFORE_FLASH * settings.sampRate);
    currEpochStimStart = epochStartInds(i);
    currEpochEnd = epochStartInds(i) + ( DURATION_TO_PLOT_PER_EPOCH * settings.sampRate);
    
    currTimeArray = timeArray( currEpochStart : currEpochEnd) ;
    currTimeArray = currTimeArray - currTimeArray(1); % offset to start at t = 0 for plot;
    
    currVoltage = dataTrace( currEpochStart : currEpochEnd);
    currVoltage = currVoltage + (OFFSET_FOR_PLOT * -1*(i - 1) );% offset to see all the traces over eachother
    
    plot(currTimeArray, currVoltage); hold on;
    traces(i, :) = currVoltage;
    box off;
    
    % Find ave Vm in 0,5 second before stimuluation
    preStimVoltage = dataTrace( currEpochStart : currEpochStimStart);
    preStimAve(i) = mean(preStimVoltage ( length( preStimVoltage ) - (EPOCH_TO_FIND_BASELINE * settings.sampRate ) : end ) );
    
    %plot( currTimeArray , preStimAve(i) * ones( 1, length(currTimeArray)));
    % Find min Vm in second following stimulation
    postStimVoltage = dataTrace( currEpochStimStart : currEpochEnd);
    postStimMin(i) = min(postStimVoltage (1 : EPOCH_TO_FIND_MINIMUM * settings.sampRate ) );
    %plot( currTimeArray , postStimMin(i) * ones( 1, length(currTimeArray)));
    
    
    currStim = stimulus.shutterCommand( currEpochStart: currEpochEnd);
    STIM_OFFSET = -95;
    STIM_SCALE = 100;
    plot(currTimeArray, (currStim* STIM_SCALE) + STIM_OFFSET , 'k'); hold on;
    
    
%     % time till 1/2 min response for this trial
%     currHalfMinVm = preStimAve(i) + (( postStimMin(i) - preStimAve(i) )/2);
%     
%     % find when trace first passes under this value
%     firstSampleBelowHalfMinVm(i)  = find( postStimVoltage (1 : EPOCH_TO_FIND_MINIMUM * settings.sampRate ) < currHalfMinVm , 1 ,'first');
%     
%     % find lateny from shutter opening till trace passing this value:
%      responseLatencyToHalfMin_sec(i) = firstSampleBelowHalfMinVm(i) / ( settings.sampRate); % seconds
end

epochStartInd = 1;
epochStimStart = DURATION_TO_PLOT_BEFORE_FLASH * settings.sampRate;
epochEndInd = epochStimStart + DURATION_TO_PLOT_PER_EPOCH * settings.sampRate;

meanTrace = mean( traces );
% find peak of the meanTrace after the epoch
preStimMeanTrace = meanTrace( epochStartInd : epochStimStart);
preStimMeanVoltage = mean( preStimMeanTrace );

postStimMeanTrace = meanTrace( epochStimStart : epochEndInd);
postStimMinVoltage = min( postStimMeanTrace );

IPSP_meanAmp = postStimMinVoltage - preStimMeanVoltage;

PERCENTAGE_OF_MIN_FOR_LATENCY = 0.1;
% find latency when meanTrace passes 5% of max response
     fractionMinVm = preStimMeanVoltage + (( postStimMinVoltage - preStimMeanVoltage )* PERCENTAGE_OF_MIN_FOR_LATENCY);
    
     % find when trace first passes under this value
     firstSampleBelowMinVm  = find( postStimMeanTrace  < fractionMinVm , 1 ,'first');
%     
%     % find lateny from shutter opening till trace passing this value:
      responseLatencyToPercentageMin_sec = firstSampleBelowMinVm / ( settings.sampRate); % seconds


% IPSP_amp=[];
% % calculate IPSP amplitudes:
% IPSP_amp = postStimMin - preStimAve;

% IPSP_mean = mean( IPSP_amp );
% latency_mean = mean( responseLatencyToHalfMin_sec );
% Vrest_mean = mean(preStimAve);

% add average IPSP plotp
plot( currTimeArray,meanTrace , '-k' );

PLOT_SCALE_OFFSET = 10; % mV
 Vm_mean = mean( preStimAve );
ylim([ (Vm_mean + IPSP_meanAmp - PLOT_SCALE_OFFSET) , (Vm_mean + PLOT_SCALE_OFFSET) ])
xlabel('s')
ylabel('mV')
title( [ 'IPSP ave: '   num2str( round( IPSP_meanAmp ,2) ) 'mV, Latency till halfmin = ' num2str( round( responseLatencyToPercentageMin_sec,4) ) ] )

IPSP_meanAmp
responseLatencyToPercentageMin_sec

%% Summery plots for mean effect and latency here:

figure;
set(gcf, 'Color', 'w');
set(gca,'TickDir','out'); % The only other option is 'in'

aveResponseAmp = [-17.0318000000000;-27.5632000000000;-7.59350000000000;-13.9976000000000;-14.5940000000000;-14.2077000000000;-15.0816000000000];
aveResponseLatency = [0.0130000000000000;0.0273000000000000;0.0449000000000000;0.0130000000000000;0.0117000000000000;0.0140000000000000;0.0115000000000000];

plotSpread( aveResponseAmp, 'showMM', 2 );
ylim([ -30,0]);
ylabel('mV')
niceaxes
title('R19C08 chrimson, mean red cross');


%%
figure;
set(gcf, 'Color', 'w');
set(gca,'TickDir','out'); % The only other option is 'in'

aveResponseAmpR2 = [-17.0318000000000;-27.5632000000000;-7.59350000000000;-13.9976000000000;-14.5940000000000;-14.2077000000000;-15.0816000000000];
aveResponseAmpR2R4d = [-17.0318000000000;-27.5632000000000;-7.59350000000000;-13.9976000000000;-14.5940000000000;-14.2077000000000;-15.0816000000000;-2.00820000000000;-12.1955000000000;-8.50600000000000;-10.5615000000000];

plotSpread( aveResponseAmpR2R4d, 'showMM', 2 );
ylim([ -30,0]);
ylabel('mV')
niceaxes
title('R2 or R4d chrimson, mean red cross');



% 
% figure;
% set(gcf, 'Color', 'w');
% set(gca,'TickDir','out'); % The only other option is 'in'
% 
% plotSpread( aveResponseLatency, 'showMM', 2 );
% ylim([ 0,0.05]);


%%
aveControlResponseAmp = [-2.44210000000000;-1.52870000000000;-1.15960000000000;-2.38250000000000;-2.63290000000000];
figure;
set(gcf, 'Color', 'w');
set(gca,'TickDir','out'); % The only other option is 'in'

plotSpread( aveControlResponseAmp, 'showMM', 2 );
ylim([ -30,0]);
niceaxes
title('no chrimson control, mean red cross');
