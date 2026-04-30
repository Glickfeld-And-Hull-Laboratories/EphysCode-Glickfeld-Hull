function f = prePlot()
        globals;
        
        f = figure;
        f.Position = [globalX globalY globalW globalH];
        left_color = [0 0 0];
        right_color = COLOR_BLIND_FRIENDLY_GREEN; %[0 .5 .5];
        set(f,'defaultAxesColorOrder',[right_color; right_color]);
        hold on          
end