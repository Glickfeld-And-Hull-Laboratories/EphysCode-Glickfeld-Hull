clear TrainingDataSum

TrainingDataSum(1).animal = [];
TrainingDataSum(1).day1 = [];
TrainingDataSum(1).day2 = [];
TrainingDataSum(1).day3 = [];
TrainingDataSum(1).day4 = [];
TrainingDataSum(1).day5 = [];
TrainingDataSum(1).day6 = [];
TrainingDataSum(1).day7 = [];
TrainingDataSum(1).day8 = [];
TrainingDataSum(1).day9 = [];
TrainingDataSum(1).day10 = [];
TrainingDataSum(1).day11 = [];
TrainingDataSum(1).day12 = [];
TrainingDataSum(1).day13 = [];
TrainingDataSum(1).day14 = [];
TrainingDataSum(1).day15 = [];
TrainingDataSum(1).day16 = [];
TrainingDataSum(1).day17 = [];
TrainingDataSum(1).day18 = [];
TrainingDataSum(1).day19 = [];
TrainingDataSum(1).day20 = [];
TrainingDataSum(1).day21 = [];
TrainingDataSum(1).day22 = [];
TrainingDataSum(1).day23 = [];
TrainingDataSum(1).day24 = [];
TrainingDataSum(1).day25 = [];
TrainingDataSum(1).day26 = [];



TrainingDataSum(1).animal = 1697;
RecordingListTemp = RecordingList([RecordingList.mouse] == TrainingDataSum(1).animal);

rLcounter = 1; % change this when using RecordingListTemp with more animals

TrainingDataSum(1).day1.AllLicks = RecordingListTemp(rLcounter).AllLicks;
TrainingDataSum(1).day1.TrialStruct = RecordingListTemp(rLcounter).TrialStruct;
TrainingDataSum(1).day1.TrialStruct_clk = RecordingListTemp(rLcounter).TrialStruct_clk;
[TrainingDataSum(1).day1.TrialStruct_sil, ~] = RTtone(RecordingListTemp(rLcounter).TrialStruct_sil, RecordingListTemp(rLcounter).AllLicks, .5);
TrainingDataSum(1).day1.JuiceTimes_sil = RecordingListTemp(rLcounter).JuiceTimes_sil;
TrainingDataSum(1).day1.day = 1;
rLcounter = rLcounter + 1;

TrainingDataSum(1).day2.AllLicks = RecordingListTemp(rLcounter).AllLicks;
TrainingDataSum(1).day2.TrialStruct = RecordingListTemp(rLcounter).TrialStruct;
TrainingDataSum(1).day2.TrialStruct_clk = RecordingListTemp(rLcounter).TrialStruct_clk;
[TrainingDataSum(1).day2.TrialStruct_sil, ~] = RTtone(RecordingListTemp(rLcounter).TrialStruct_sil, RecordingListTemp(rLcounter).AllLicks, .5);
TrainingDataSum(1).day2.JuiceTimes_sil = RecordingListTemp(rLcounter).JuiceTimes_sil;
TrainingDataSum(1).day2.day = 2;
rLcounter = rLcounter + 1;

TrainingDataSum(1).day3.AllLicks = RecordingListTemp(rLcounter).AllLicks;
TrainingDataSum(1).day3.TrialStruct = RecordingListTemp(rLcounter).TrialStruct;
TrainingDataSum(1).day3.TrialStruct_clk = RecordingListTemp(rLcounter).TrialStruct_clk;
[TrainingDataSum(1).day3.TrialStruct_sil, ~] = RTtone(RecordingListTemp(rLcounter).TrialStruct_sil, RecordingListTemp(rLcounter).AllLicks, .5);
TrainingDataSum(1).day3.JuiceTimes_sil = RecordingListTemp(rLcounter).JuiceTimes_sil;
TrainingDataSum(1).day3.day = 3;
rLcounter = rLcounter + 1;

TrainingDataSum(1).day4.AllLicks = RecordingListTemp(rLcounter).AllLicks;
TrainingDataSum(1).day4.TrialStruct = RecordingListTemp(rLcounter).TrialStruct;
TrainingDataSum(1).day4.TrialStruct_clk = RecordingListTemp(rLcounter).TrialStruct_clk;
[TrainingDataSum(1).day4.TrialStruct_sil, ~] = RTtone(RecordingListTemp(rLcounter).TrialStruct_sil, RecordingListTemp(rLcounter).AllLicks, .5);
TrainingDataSum(1).day4.JuiceTimes_sil = RecordingListTemp(rLcounter).JuiceTimes_sil;
TrainingDataSum(1).day4.day = 4;
rLcounter = rLcounter + 1;

TrainingDataSum(1).day6.AllLicks = RecordingListTemp(rLcounter).AllLicks;
TrainingDataSum(1).day6.TrialStruct = RecordingListTemp(rLcounter).TrialStruct;
TrainingDataSum(1).day6.TrialStruct_clk = RecordingListTemp(rLcounter).TrialStruct_clk;
[TrainingDataSum(1).day6.TrialStruct_sil, ~] = RTtone(RecordingListTemp(rLcounter).TrialStruct_sil, RecordingListTemp(rLcounter).AllLicks, .5);
TrainingDataSum(1).day6.JuiceTimes_sil = RecordingListTemp(rLcounter).JuiceTimes_sil;
TrainingDataSum(1).day6.day = 6;
rLcounter = rLcounter + 1;

TrainingDataSum(1).day7.AllLicks = RecordingListTemp(rLcounter).AllLicks;
TrainingDataSum(1).day7.TrialStruct = RecordingListTemp(rLcounter).TrialStruct;
TrainingDataSum(1).day7.TrialStruct_clk = RecordingListTemp(rLcounter).TrialStruct_clk;
[TrainingDataSum(1).day7.TrialStruct_sil, ~] = RTtone(RecordingListTemp(rLcounter).TrialStruct_sil, RecordingListTemp(rLcounter).AllLicks, .5);
TrainingDataSum(1).day7.JuiceTimes_sil = RecordingListTemp(rLcounter).JuiceTimes_sil;
TrainingDataSum(1).day7.day = 7;
rLcounter = rLcounter + 1;

TrainingDataSum(2).animal = 1695;
RecordingListTemp = RecordingList([RecordingList.mouse] == TrainingDataSum(2).animal);

rLcounter = 1; % change this when using RecordingListTemp with more animals

TrainingDataSum(2).day1.AllLicks = RecordingListTemp(rLcounter).AllLicks;
TrainingDataSum(2).day1.TrialStruct = RecordingListTemp(rLcounter).TrialStruct;
TrainingDataSum(2).day1.TrialStruct_clk = RecordingListTemp(rLcounter).TrialStruct_clk;
[TrainingDataSum(2).day1.TrialStruct_sil, ~] = RTtone(RecordingListTemp(rLcounter).TrialStruct_sil, RecordingListTemp(rLcounter).AllLicks, .5);
TrainingDataSum(2).day1.JuiceTimes_sil = RecordingListTemp(rLcounter).JuiceTimes_sil;
TrainingDataSum(2).day1.day = 1;
rLcounter = rLcounter + 1;

TrainingDataSum(2).day2.AllLicks = RecordingListTemp(rLcounter).AllLicks;
TrainingDataSum(2).day2.TrialStruct = RecordingListTemp(rLcounter).TrialStruct;
TrainingDataSum(2).day2.TrialStruct_clk = RecordingListTemp(rLcounter).TrialStruct_clk;
[TrainingDataSum(2).day2.TrialStruct_sil, ~] = RTtone(RecordingListTemp(rLcounter).TrialStruct_sil, RecordingListTemp(rLcounter).AllLicks, .5);
TrainingDataSum(2).day2.JuiceTimes_sil = RecordingListTemp(rLcounter).JuiceTimes_sil;
TrainingDataSum(2).day2.day = 2;
rLcounter = rLcounter + 1;

TrainingDataSum(2).day3.AllLicks = RecordingListTemp(rLcounter).AllLicks;
TrainingDataSum(2).day3.TrialStruct = RecordingListTemp(rLcounter).TrialStruct;
TrainingDataSum(2).day3.TrialStruct_clk = RecordingListTemp(rLcounter).TrialStruct_clk;
[TrainingDataSum(2).day3.TrialStruct_sil, ~] = RTtone(RecordingListTemp(rLcounter).TrialStruct_sil, RecordingListTemp(rLcounter).AllLicks, .5);
TrainingDataSum(2).day3.JuiceTimes_sil = RecordingListTemp(rLcounter).JuiceTimes_sil;
TrainingDataSum(2).day3.day= 3;
rLcounter = rLcounter + 1;

TrainingDataSum(2).day6.AllLicks = RecordingListTemp(rLcounter).AllLicks;
TrainingDataSum(2).day6.TrialStruct = RecordingListTemp(rLcounter).TrialStruct;
TrainingDataSum(2).day6.TrialStruct_clk = RecordingListTemp(rLcounter).TrialStruct_clk;
[TrainingDataSum(2).day6.TrialStruct_sil, ~] = RTtone(RecordingListTemp(rLcounter).TrialStruct_sil, RecordingListTemp(rLcounter).AllLicks, .5);
TrainingDataSum(2).day6.JuiceTimes_sil = RecordingListTemp(rLcounter).JuiceTimes_sil;
TrainingDataSum(2).day6.day = 6;
rLcounter = rLcounter + 1;

TrainingDataSum(2).day7.AllLicks = RecordingListTemp(rLcounter).AllLicks;
TrainingDataSum(2).day7.TrialStruct = RecordingListTemp(rLcounter).TrialStruct;
TrainingDataSum(2).day7.TrialStruct_clk = RecordingListTemp(rLcounter).TrialStruct_clk;
[TrainingDataSum(2).day7.TrialStruct_sil, ~] = RTtone(RecordingListTemp(rLcounter).TrialStruct_sil, RecordingListTemp(rLcounter).AllLicks, .5);
TrainingDataSum(2).day7.JuiceTimes_sil = RecordingListTemp(rLcounter).JuiceTimes_sil;
TrainingDataSum(2).day7.day = 7;
rLcounter = rLcounter + 1;

TrainingDataSum(2).day8.AllLicks = RecordingListTemp(rLcounter).AllLicks;
TrainingDataSum(2).day8.TrialStruct = RecordingListTemp(rLcounter).TrialStruct;
TrainingDataSum(2).day8.TrialStruct_clk = RecordingListTemp(rLcounter).TrialStruct_clk;
[TrainingDataSum(2).day8.TrialStruct_sil, ~] = RTtone(RecordingListTemp(rLcounter).TrialStruct_sil, RecordingListTemp(rLcounter).AllLicks, .5);
TrainingDataSum(2).day8.JuiceTimes_sil = RecordingListTemp(rLcounter).JuiceTimes_sil;
TrainingDataSum(2).day8.day = 8;
rLcounter = rLcounter + 1;

TrainingDataSum(2).day11.AllLicks = RecordingListTemp(rLcounter).AllLicks;
TrainingDataSum(2).day11.TrialStruct = RecordingListTemp(rLcounter).TrialStruct;
TrainingDataSum(2).day11.TrialStruct_clk = RecordingListTemp(rLcounter).TrialStruct_clk;
[TrainingDataSum(2).day11.TrialStruct_sil, ~] = RTtone(RecordingListTemp(rLcounter).TrialStruct_sil, RecordingListTemp(rLcounter).AllLicks, .5);
TrainingDataSum(2).day11.JuiceTimes_sil = RecordingListTemp(rLcounter).JuiceTimes_sil;
TrainingDataSum(2).day11.day = 11;
rLcounter = rLcounter + 1;

TrainingDataSum(2).day12.AllLicks = RecordingListTemp(rLcounter).AllLicks;
TrainingDataSum(2).day12.TrialStruct = RecordingListTemp(rLcounter).TrialStruct;
TrainingDataSum(2).day12.TrialStruct_clk = RecordingListTemp(rLcounter).TrialStruct_clk;
[TrainingDataSum(2).day12.TrialStruct_sil, ~] = RTtone(RecordingListTemp(rLcounter).TrialStruct_sil, RecordingListTemp(rLcounter).AllLicks, .5);
TrainingDataSum(2).day12.JuiceTimes_sil = RecordingListTemp(rLcounter).JuiceTimes_sil;
TrainingDataSum(2).day12.day = 12;
rLcounter = rLcounter + 1;

TrainingDataSum(2).day13.AllLicks = RecordingListTemp(rLcounter).AllLicks;
TrainingDataSum(2).day13.TrialStruct = RecordingListTemp(rLcounter).TrialStruct;
TrainingDataSum(2).day13.TrialStruct_clk = RecordingListTemp(rLcounter).TrialStruct_clk;
[TrainingDataSum(2).day13.TrialStruct_sil, ~] = RTtone(RecordingListTemp(rLcounter).TrialStruct_sil, RecordingListTemp(rLcounter).AllLicks, .5);
TrainingDataSum(2).day13.JuiceTimes_sil = RecordingListTemp(rLcounter).JuiceTimes_sil;
TrainingDataSum(2).day13.day = 13;
rLcounter = rLcounter + 1;

TrainingDataSum(2).day14.AllLicks = RecordingListTemp(rLcounter).AllLicks;
TrainingDataSum(2).day14.TrialStruct = RecordingListTemp(rLcounter).TrialStruct;
TrainingDataSum(2).day14.TrialStruct_clk = RecordingListTemp(rLcounter).TrialStruct_clk;
[TrainingDataSum(2).day14.TrialStruct_sil, ~] = RTtone(RecordingListTemp(rLcounter).TrialStruct_sil, RecordingListTemp(rLcounter).AllLicks, .5);
TrainingDataSum(2).day14.JuiceTimes_sil = RecordingListTemp(rLcounter).JuiceTimes_sil;
TrainingDataSum(2).day14.day = 14;
rLcounter = rLcounter + 1;

TrainingDataSum(2).day16.AllLicks = RecordingListTemp(rLcounter).AllLicks;
TrainingDataSum(2).day16.TrialStruct = RecordingListTemp(rLcounter).TrialStruct;
TrainingDataSum(2).day16.TrialStruct_clk = RecordingListTemp(rLcounter).TrialStruct_clk;
[TrainingDataSum(2).day16.TrialStruct_sil, ~] = RTtone(RecordingListTemp(rLcounter).TrialStruct_sil, RecordingListTemp(rLcounter).AllLicks, .5);
TrainingDataSum(2).day16.JuiceTimes_sil = RecordingListTemp(rLcounter).JuiceTimes_sil;
TrainingDataSum(2).day16.day = 16;
rLcounter = rLcounter + 1;

TrainingDataSum(2).day19.AllLicks = RecordingListTemp(rLcounter).AllLicks;
TrainingDataSum(2).day19.TrialStruct = RecordingListTemp(rLcounter).TrialStruct;
TrainingDataSum(2).day19.TrialStruct_clk = RecordingListTemp(rLcounter).TrialStruct_clk;
[TrainingDataSum(2).day19.TrialStruct_sil, ~] = RTtone(RecordingListTemp(rLcounter).TrialStruct_sil, RecordingListTemp(rLcounter).AllLicks, .5);
TrainingDataSum(2).day19.JuiceTimes_sil = RecordingListTemp(rLcounter).JuiceTimes_sil;
TrainingDataSum(2).day19.day = 19;
rLcounter = rLcounter + 1;

TrainingDataSum(2).day23.AllLicks = RecordingListTemp(rLcounter).AllLicks;
TrainingDataSum(2).day23.TrialStruct = RecordingListTemp(rLcounter).TrialStruct;
TrainingDataSum(2).day23.TrialStruct_clk = RecordingListTemp(rLcounter).TrialStruct_clk;
[TrainingDataSum(2).day23.TrialStruct_sil, ~] = RTtone(RecordingListTemp(rLcounter).TrialStruct_sil, RecordingListTemp(rLcounter).AllLicks, .5);
TrainingDataSum(2).day23.JuiceTimes_sil = RecordingListTemp(rLcounter).JuiceTimes_sil;
TrainingDataSum(2).day23.day = 13;
rLcounter = rLcounter + 1;

TrainingDataSum(2).day25.AllLicks = RecordingListTemp(rLcounter).AllLicks;
TrainingDataSum(2).day25.TrialStruct = RecordingListTemp(rLcounter).TrialStruct;
TrainingDataSum(2).day25.TrialStruct_clk = RecordingListTemp(rLcounter).TrialStruct_clk;
[TrainingDataSum(2).day25.TrialStruct_sil, ~] = RTtone(RecordingListTemp(rLcounter).TrialStruct_sil, RecordingListTemp(rLcounter).AllLicks, .5);
TrainingDataSum(2).day25.JuiceTimes_sil = RecordingListTemp(rLcounter).JuiceTimes_sil;
TrainingDataSum(2).day25.day = 25;
rLcounter = rLcounter + 1;

TrainingDataSum(2).day26.AllLicks = RecordingListTemp(rLcounter).AllLicks;
TrainingDataSum(2).day26.TrialStruct = RecordingListTemp(rLcounter).TrialStruct;
TrainingDataSum(2).day26.TrialStruct_clk = RecordingListTemp(rLcounter).TrialStruct_clk;
[TrainingDataSum(2).day26.TrialStruct_sil, ~] = RTtone(RecordingListTemp(rLcounter).TrialStruct_sil, RecordingListTemp(rLcounter).AllLicks, .5);
TrainingDataSum(2).day26.JuiceTimes_sil = RecordingListTemp(rLcounter).JuiceTimes_sil;
TrainingDataSum(2).day26.day = 26;
rLcounter = rLcounter + 1;

TrainingDataSum(3).animal = 1694;
RecordingListTemp = RecordingList([RecordingList.mouse] == TrainingDataSum(3).animal);

rLcounter = 1; % change this when using RecordingListTemp with more animals

TrainingDataSum(3).day1.AllLicks = RecordingListTemp(rLcounter).AllLicks;
TrainingDataSum(3).day1.TrialStruct = RecordingListTemp(rLcounter).TrialStruct;
TrainingDataSum(3).day1.TrialStruct_clk = RecordingListTemp(rLcounter).TrialStruct_clk;
[TrainingDataSum(3).day1.TrialStruct_sil, ~] = RTtone(RecordingListTemp(rLcounter).TrialStruct_sil, RecordingListTemp(rLcounter).AllLicks, .5);
TrainingDataSum(3).day1.JuiceTimes_sil = RecordingListTemp(rLcounter).JuiceTimes_sil;
TrainingDataSum(3).day1.day = 1;
rLcounter = rLcounter + 1;

TrainingDataSum(3).day2.AllLicks = RecordingListTemp(rLcounter).AllLicks;
TrainingDataSum(3).day2.TrialStruct = RecordingListTemp(rLcounter).TrialStruct;
TrainingDataSum(3).day2.TrialStruct_clk = RecordingListTemp(rLcounter).TrialStruct_clk;
[TrainingDataSum(3).day2.TrialStruct_sil, ~] = RTtone(RecordingListTemp(rLcounter).TrialStruct_sil, RecordingListTemp(rLcounter).AllLicks, .5);
TrainingDataSum(3).day2.JuiceTimes_sil = RecordingListTemp(rLcounter).JuiceTimes_sil;
TrainingDataSum(3).day2.day = 2;
rLcounter = rLcounter + 1;

TrainingDataSum(3).day3.AllLicks = RecordingListTemp(rLcounter).AllLicks;
TrainingDataSum(3).day3.TrialStruct = RecordingListTemp(rLcounter).TrialStruct;
TrainingDataSum(3).day3.TrialStruct_clk = RecordingListTemp(rLcounter).TrialStruct_clk;
[TrainingDataSum(3).day3.TrialStruct_sil, ~] = RTtone(RecordingListTemp(rLcounter).TrialStruct_sil, RecordingListTemp(rLcounter).AllLicks, .5);
TrainingDataSum(3).day3.JuiceTimes_sil = RecordingListTemp(rLcounter).JuiceTimes_sil;
TrainingDataSum(3).day3.day = 3;
rLcounter = rLcounter + 1;

TrainingDataSum(3).day7.AllLicks = RecordingListTemp(rLcounter).AllLicks;
TrainingDataSum(3).day7.TrialStruct = RecordingListTemp(rLcounter).TrialStruct;
TrainingDataSum(3).day7.TrialStruct_clk = RecordingListTemp(rLcounter).TrialStruct_clk;
[TrainingDataSum(3).day7.TrialStruct_sil, ~] = RTtone(RecordingListTemp(rLcounter).TrialStruct_sil, RecordingListTemp(rLcounter).AllLicks, .5);
TrainingDataSum(3).day7.JuiceTimes_sil = RecordingListTemp(rLcounter).JuiceTimes_sil;
TrainingDataSum(3).day7.day = 7;
rLcounter = rLcounter + 1;

TrainingDataSum(3).day10.AllLicks = RecordingListTemp(rLcounter).AllLicks;
TrainingDataSum(3).day10.TrialStruct = RecordingListTemp(rLcounter).TrialStruct;
TrainingDataSum(3).day10.TrialStruct_clk = RecordingListTemp(rLcounter).TrialStruct_clk;
[TrainingDataSum(3).day10.TrialStruct_sil, ~] = RTtone(RecordingListTemp(rLcounter).TrialStruct_sil, RecordingListTemp(rLcounter).AllLicks, .5);
TrainingDataSum(3).day10.JuiceTimes_sil = RecordingListTemp(rLcounter).JuiceTimes_sil;
TrainingDataSum(3).day10.day = 10;
rLcounter = rLcounter + 1;

TrainingDataSum(3).day13.AllLicks = RecordingListTemp(rLcounter).AllLicks;
TrainingDataSum(3).day13.TrialStruct = RecordingListTemp(rLcounter).TrialStruct;
TrainingDataSum(3).day13.TrialStruct_clk = RecordingListTemp(rLcounter).TrialStruct_clk;
[TrainingDataSum(3).day13.TrialStruct_sil, ~] = RTtone(RecordingListTemp(rLcounter).TrialStruct_sil, RecordingListTemp(rLcounter).AllLicks, .5);
TrainingDataSum(3).day13.JuiceTimes_sil = RecordingListTemp(rLcounter).JuiceTimes_sil;
TrainingDataSum(3).day13.day = 13;
rLcounter = rLcounter + 1;

TrainingDataSum(3).day18.AllLicks = RecordingListTemp(rLcounter).AllLicks;
TrainingDataSum(3).day18.TrialStruct = RecordingListTemp(rLcounter).TrialStruct;
TrainingDataSum(3).day18.TrialStruct_clk = RecordingListTemp(rLcounter).TrialStruct_clk;
[TrainingDataSum(3).day18.TrialStruct_sil, ~] = RTtone(RecordingListTemp(rLcounter).TrialStruct_sil, RecordingListTemp(rLcounter).AllLicks, .5);
TrainingDataSum(3).day18.JuiceTimes_sil = RecordingListTemp(rLcounter).JuiceTimes_sil;
TrainingDataSum(3).day18.day = 18;
rLcounter = rLcounter + 1;

TrainingDataSum(3).day21.AllLicks = RecordingListTemp(rLcounter).AllLicks;
TrainingDataSum(3).day21.TrialStruct = RecordingListTemp(rLcounter).TrialStruct;
TrainingDataSum(3).day21.TrialStruct_clk = RecordingListTemp(rLcounter).TrialStruct_clk;
[TrainingDataSum(3).day21.TrialStruct_sil, ~] = RTtone(RecordingListTemp(rLcounter).TrialStruct_sil, RecordingListTemp(rLcounter).AllLicks, .5);
TrainingDataSum(3).day21.JuiceTimes_sil = RecordingListTemp(rLcounter).JuiceTimes_sil;
TrainingDataSum(3).day21.day = 21;
rLcounter = rLcounter + 1;

TrainingDataSum(3).day23.AllLicks = RecordingListTemp(rLcounter).AllLicks;
TrainingDataSum(3).day23.TrialStruct = RecordingListTemp(rLcounter).TrialStruct;
TrainingDataSum(3).day23.TrialStruct_clk = RecordingListTemp(rLcounter).TrialStruct_clk;
[TrainingDataSum(3).day23.TrialStruct_sil, ~] = RTtone(RecordingListTemp(rLcounter).TrialStruct_sil, RecordingListTemp(rLcounter).AllLicks, .5);
TrainingDataSum(3).day23.JuiceTimes_sil = RecordingListTemp(rLcounter).JuiceTimes_sil;
TrainingDataSum(3).day23.day = 23;
rLcounter = rLcounter + 1;

F1 = fieldnames(TrainingDataSum);
for g = 1:length(TrainingDataSum)
    if ~isempty(TrainingDataSum(g))
        TempCell = struct2cell(TrainingDataSum(g));
    end
    for p = 2:length(TempCell)
        if ~isempty(TempCell{p})
            day = TempCell{p}.day;
            mouse = TrainingDataSum(g).animal;
            for n = 1:length(RecordingList)
                if RecordingList(n).mouse == mouse & RecordingList(n).day == day
            TrainingDataSum(g).(F1{p}).RecorNum = n;
                end
            end
        end
    end
end

            
            
