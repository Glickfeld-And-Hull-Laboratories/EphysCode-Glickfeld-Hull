%use with behav_analysis_movingDots
%find SpeedTimes for running, stationary, back and forth,
%generate cell for stationary windows, running windows, and moving windows
%(running+back and forth)

function [RunMetaData, Index_stay_cell, Index_move_cell, Index_forwardrun_cell, StillTrigA, StillTrigB, moveTrigA, moveTrigB] = find_behavStatesMEH(SpeedTimes, speed)
%speed is SpeedValues

if ~isempty(SpeedTimes) & ~isempty(speed)

    ZeroMax = .5; %max speed considered zero
    Index = 1: length(speed);
    transient_stay = 5; %length in bins of a stay that is considered too short to include;
    MoveMinDura = 5; %length in bins of a movement segment that is considered too short to include;
    frm_maxGap = 2; %max bins to allow of no movement during movement periods + 1; i.e. maxGap 1 = allow zero bins of no movement;
    forwardrunMinDura = 5; %length in bins of a forward run that is considered to short to include
    BinSize = SpeedTimes(2)-SpeedTimes(1);

    RunMetaData.ZeroMax = ZeroMax;
    RunMetaData.transient_stay = transient_stay;
    RunMetaData.MoveMinDura = MoveMinDura;
    RunMetaData.frm_maxGap = frm_maxGap;
    RunMetaData.frm_maxGap = frm_maxGap;
    RunMetaData.BinSize = BinSize;

    %% generate a cell for stay parts
    Index_stay_cell = {};
    Index_stay = Index(abs(speed) < ZeroMax);
    bound_stay = find(diff(Index_stay)~=1);
    for j = 1:length(bound_stay)
        if j == 1
            Index_stay_cell{j} = Index(1:bound_stay(1));
        else
            Index_stay_cell = cat(2, Index_stay_cell, Index_stay(bound_stay(j-1)+1):Index_stay(bound_stay(j)));
        end
    end
    % delete the parts that are too short

    for k = 1: size(Index_stay_cell,2)
        if length(Index_stay_cell{k}) <= transient_stay
            Index_stay_cell{k} = [];
        end
    end
    empties = find(cellfun(@isempty,Index_stay_cell));
    Index_stay_cell(empties) = [];


    %% find SpeedTimes for move
    Index_move = Index(abs(speed) > ZeroMax);
    diff_Index_move = diff(Index_move);
    bound_move = find(diff_Index_move>frm_maxGap);
    % put continuous Index together, generate a cell for all running parts
    Index_move_cell ={};
    for j = 1:length(bound_move)
        if j == 1
            Index_move_cell{j} = Index_move(1):Index_move(bound_move(j));
        else
            Index_move_cell{j} = Index_move(bound_move(j-1)+1):Index_move(bound_move(j));
        end
    end

    %delete the parts that are too short

    for k = 1: size(Index_move_cell,2)
        if length(Index_move_cell{k}) <= MoveMinDura
            Index_move_cell{k} = [];
        end
    end
    empties = find(cellfun(@isempty,Index_move_cell));
    Index_move_cell(empties) = [];

    %% find back and forth parts (SpeedTimes_bf_cell), and run parts
    %SpeedTimes_bf_cell = {};
    Index_forwardrun_cell = {};

    Index_forwardrun = Index(speed > ZeroMax);
    diff_Index_forwardrun = diff(Index_forwardrun);
    bound_forwardrun = find(diff_Index_forwardrun ~=1);
    % put continuous Index together, generate a cell for all running parts
    Index_forwardrun_cell ={};
    for j = 1:length(bound_forwardrun)
        if j == 1
            Index_forwardrun_cell{j} = Index_forwardrun(1):Index_forwardrun(bound_forwardrun(j));
        else
            Index_forwardrun_cell{j} = Index_forwardrun(bound_forwardrun(j-1)+1):Index_forwardrun(bound_forwardrun(j));
        end
    end

    %delete the parts that are too short

    for k = 1: size(Index_forwardrun_cell,2)
        if length(Index_forwardrun_cell{k}) <= forwardrunMinDura
            Index_forwardrun_cell{k} = [];
        end
    end
    empties = find(cellfun(@isempty,Index_forwardrun_cell));
    Index_forwardrun_cell(empties) = [];

    % turn Index_stay into Triggers to use with AllLicks for quiescent times
    for n = 1:length(Index_stay_cell)
        StillTrigA(n) = SpeedTimes(Index_stay_cell{1,n}(1));
        StillTrigB(n) = SpeedTimes(Index_stay_cell{1,n}(end));
    end
    for n = 1:length(Index_move_cell)
        moveTrigA(n) = SpeedTimes(Index_move_cell{1,n}(1));
        moveTrigB(n) = SpeedTimes(Index_move_cell{1,n}(end));
    end
else
    RunMetaData = [];
    Index_stay_cell = [];
    Index_move_cell = [];
    Index_forwardrun_cell = [];
    StillTrigA = [];
    StillTrigB = [];
    moveTrigA = [];
    moveTrigB = [];
end







