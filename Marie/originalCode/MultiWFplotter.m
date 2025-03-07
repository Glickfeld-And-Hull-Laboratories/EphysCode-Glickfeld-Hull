function MultiWFplotter(wfStructStruct, TL1, TL2, STIM)
%TL1, TL2, STIM are boolians indication plots on or off or TimeLim1,
%TimeLim2, and StimWFs that are spit out by MultiChanWF and/or
%CellCharWorkup
figure
hold on

%set colors for the plots
col_TL1 = 'k';
col_TL2 = 'm';
col_STIM = 'b';

%these variables are generally the same for the whole sub-structure
time = wfStructStruct(1).time;

if TL1
    color = col_TL1;
    Scale = wfStructStruct.TGlim1WFs(1).Scale;
    for n = 1:length(wfStructStruct.TGlim1WFs)
        plot(time+ wfStructStruct.TGlim1WFs(n).X/5000, wfStructStruct.TGlim1WFs(n).AvgWf+wfStructStruct.TGlim1WFs(n).Y*Scale/30, color);
        textx = time(end/3) + wfStructStruct.TGlim1WFs(n).X/5000;
        texty = max(wfStructStruct.TGlim1WFs(n).AvgWf + wfStructStruct.TGlim1WFs(n).Y*Scale/30)+.00005;
        text(textx, texty, num2str(wfStructStruct.TGlim1WFs(n).Chan)); 
    end
         for s = 1:length(wfStructStruct.TGlim1WFs)
            Sizer(1,s) = max(wfStructStruct.TGlim1WFs(s).AvgWf) - min(wfStructStruct.TGlim1WFs(s).AvgWf);
        end
        [~, I] = max(Sizer);
        BiggestChan = wfStructStruct.TGlim1WFs(I).Chan;
        BiggestWF = wfStructStruct.TGlim1WFs(I).AvgWf;
        plot(time+ wfStructStruct.TGlim1WFs(I).X/5000, BiggestWF+wfStructStruct.TGlim1WFs(I).Y*Scale/30, color, 'LineWidth', 2);

end


if TL2
    color = col_TL2;
    Scale = wfStructStruct.TGlim2WFs(1).Scale;
    for n = 1:length(wfStructStruct.TGlim2WFs)
        plot(time+ wfStructStruct.TGlim2WFs(n).X/5000, wfStructStruct.TGlim2WFs(n).AvgWf+wfStructStruct.TGlim2WFs(n).Y*Scale/30, color, 'LineWidth', 0.5);
    end
        
end

if STIM
    color = col_STIM;
    Scale = wfStructStruct.StimWFs(1).Scale;
    for n = 1:length(wfStructStruct.StimWFs)
        plot(time+ wfStructStruct.StimWFs(n).X/5000, wfStructStruct.StimWFs(n).AvgWf+wfStructStruct.StimWFs(n).Y*Scale/30, color, 'LineWidth', 0.5);
    end
       
end

f = gca;
Xzero = f.XLim(1);
Yzero = f.YLim(1);
plot([Xzero, Xzero+.003], [Yzero, Yzero], 'k', 'LineWidth', 1); %3 ms line
plot([Xzero, Xzero], [Yzero, Yzero + .0005], 'k', 'LineWidth', 1); %1/2 mV line
text(Xzero + .0005, Yzero - .0001, '3 msec');
h = text(Xzero - .0007, Yzero + .00015, '0.5 mV');
set(h,'Rotation',90);

axis off;
FormatFigure;
%title([num2str(unit) ' on ' num2str(CenterChan)]);
hold off
end