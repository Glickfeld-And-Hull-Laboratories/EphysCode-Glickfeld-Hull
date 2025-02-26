for k = 1:length(RecordingList)
    ThisRecording = Summary([Summary.RecorNum] == k);
    k
tester =  ThisRecording(strcmp({ThisRecording.c4_label}, 'PkC_cs'));
tester = tester([tester.c4_confidence] > 2);
['CS is ' num2str(length(tester))]
tester = ThisRecording(strcmp({ThisRecording.c4_label}, 'PkC_ss'));
tester = tester([tester.c4_confidence] > 2);
['SS is ' num2str(length(tester))]
tester = ThisRecording(strcmp({ThisRecording.c4_label}, 'MFB'));
tester = tester([tester.c4_confidence] > 2);
['MF is ' num2str(length(tester))]
tester = ThisRecording(strcmp({ThisRecording.c4_label}, 'MLI'));
tester = tester([tester.c4_confidence] > 2);
['MLI is ' num2str(length(tester))]
tester = ThisRecording(strcmp({ThisRecording.c4_label}, 'GoC'));
tester = tester([tester.c4_confidence] > 2);
['Gol is ' num2str(length(tester))]
end

