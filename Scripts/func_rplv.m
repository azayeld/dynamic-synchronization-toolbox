function [rplv,trials,rplv_mean] = func_rplv(subjects,options)

%--------------------------------------------------------------------------
%----------------- Script for calculation of (r)PLV -----------------------
%--------------------------------------------------------------------------
% 
% Inputs:
%   subjects - list of ids
%   options -multiple_conds, baseline, freqs, switch_hands, channels_new,
%   channels_old, contrast, contrast_conds, averaging, avg_freqs
%
%   data - 'tph_sorted_M_lap_spmeeg_Epochs_stimulus_artefactfree_rm.mat'
%        - dimensions (elecs, freqs, time, conditions)
%--------------------------------------------------------------------------
% Written by: 
%
% Nils Rosjat
% INM-3, FZJ
% Last edited: 31.03.2020
%--------------------------------------------------------------------------

%% initialize options

multiple_conds = options.multiple_conds;
baseline = options.baseline;
freqs = options.freqs;
switch_hands = options.switch_hands;
channels_new = options.channels_new;
channels_old = options.channels_old;
contrast = options.contrast;
contrast_conds = options.contrast_conds;
averaging = options.averaging;
avg_freqs = options.avg_freqs;

%% initialize plv
rplv = cell(size(subjects,1),1);

%%% Loop calculating plv for all subjects defined above
for sub=1:size(subjects,1)
Ti=tic;
    disp(['Calculating PLV for ' subjects(sub,:)]);
    directory=subjects(sub,:);
    load(['Data/' directory '/' directory '_eeg.mat'])
    if multiple_conds
        load(['Data/' directory '/' directory '_trialSelection.mat'])
    else
        trialSelection = true(size(eegData,4),1);
    end
    
    trials(sub,:)=sum(trialSelection);       % # trials per subject (global)

    numChannels = size(eegData, 1);          % # channels
    numFreqs = size(eegData,2);              % # frequencies
    numTrials = size(eegData, 4);            % # trials (local)
    numConditions = size(trialSelection, 2); % # conditions
    
    %%% computation of single-frequency plv %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    [rplv{sub,1}]=pn_eeg_rPLV(eegData(:,freqs,:,:),trialSelection,baseline);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if switch_hands
        disp('Mapping right hand to left hand.')
        if contrast
            disp('Additionally computing the defined contrast')
            [rplv{sub,1}]=switch_hands_function(rplv{sub,1},numConditions,channels_new,channels_old);
        else
            
            [rplv{sub,1}]=switch_hands_function(rplv{sub,1},numConditions,channels_new,channels_old); 
        end
    end
    
    if contrast
        disp('Contrast')
        try
            cond1 = contrast_conds(1,1);
            cond2 = contrast_conds(1,2);
            
            [rplv{sub,1}(:,:,:,:,end+1)] = rplv{sub,1}(:,:,:,:,cond1) - rplv{sub,1}(:,:,:,:,cond2);
        catch
                disp('Two conditions need to be specified for contrasting')
        end
    end

    
    if averaging
        disp(['Averaging from ' num2str(freqs(avg_freqs(1))) 'Hz to ' num2str(freqs(avg_freqs(end))) 'Hz.'])
        [rplv{sub,1}] = average_rplv(rplv{sub,1},avg_freqs);
    end
    
    clear eegData 

    disp('Done Subject');
    toc(Ti);
end

%%% Add total amount of trials per condition to global variable %%%%%%%%%%%
for i = 1 : numConditions
    trials(size(subjects,1)+1,i)=sum(trials(1:size(subjects,1),i));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Computing group average of rPLV %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rplv_mean=rplv{1,1};                      % create data for mean plv
for i=1:size(rplv{1,1},4)
        rplv_mean(:,:,:,i)=rplv{1,1}(:,:,:,i)/size(subjects,1);
    for j=2:size(subjects,1)
        rplv_mean(:,:,:,i)=rplv_mean(:,:,:,i)+rplv{j,1}(:,:,:,i)/size(subjects,1);
    end
% end

end
