xmin= .1; 
xmax = .3;

close all
figure
for k = 1
    ThisRecording = CS([CS.RecorNum] == k);
        figure
        n = 6
    RasterMatrix = OrganizeRasterSpikesNewIndex(ThisRecording, RecordingList(k).JuiceTimes_clk, n, xmin, xmax, 'k');
    title([num2str(n) ' day ' num2str(RecordingList(k).day)]);
    for n = 1:length(CS([CS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
    
        end
    end
    
end
xlabel('time from audible reward (s)');
FigureWrap(NaN, ['exampleRasterDay' num2str(RecordingList(k).day)], NaN, NaN, NaN, NaN, NaN, NaN);
%plot the same t



close all
figure
for k = 4
    ThisRecording = CS([CS.RecorNum] == k);
        figure
        n = 30;
    RasterMatrix = OrganizeRasterSpikesNewIndex(ThisRecording, RecordingList(k).JuiceTimes_clk, n, xmin, xmax, 'k');
    title([num2str(n) ' day ' num2str(RecordingList(k).day)]);
    for n = 1:length(CS([CS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
    
        end
    end
    
end
xlabel('time from audible reward (s)');
FigureWrap(NaN, ['exampleRasterDay' num2str(RecordingList(k).day)], NaN, NaN, NaN, NaN, NaN, NaN);
%plot the same t

close all
for k = 4
    ThisRecording = CS([CS.RecorNum] == k); 
    n = 30;
    figure
    RasterMatrix = OrganizeRasterSpikesNewIndex(ThisRecording, RecordingList(k).ToneTimes, n, xmin, xmax, 'k');
    title([num2str(n) ' day ' num2str(RecordingList(k).day)]);
    for n = 1:length(CS([CS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))

        end
    end
    
end
xlabel('time from tone (s)');
FigureWrap(NaN, ['exampleRasterDay' num2str(RecordingList(k).day) '_tone'], NaN, NaN, NaN, NaN, NaN, NaN);
%plot the same t

close all
for k = 7
    ThisRecording = CS([CS.RecorNum] == k);               figure
    figure
    n = 42;
    RasterMatrix = OrganizeRasterSpikesNewIndex(ThisRecording, RecordingList(k).ToneTimes, n, xmin, xmax, 'k');
    title([num2str(n) ' day ' num2str(RecordingList(k).day)]);
        end
    for n = 1:length(CS([CS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
          
    end
    
end
xlabel('time from tone (s)');
FigureWrap(NaN, ['exampleRasterDay' num2str(RecordingList(k).day) '_tone'], NaN, NaN, NaN, NaN, NaN, NaN);
