function [TrialStruct, JuiceAlone, ToneAlone, JuiceAfterTone, ToneBeforeJuice, FictiveJuice] = JuiceToneCreateTrialSt(JuiceTimes, ToneTimes)
%FictiveJuice
len = length(ToneTimes);

for n = 1:len
    TrialPreStruct(n).type = 't';
    TrialPreStruct(n).time = ToneTimes(n);
end
if len == 0
    n = 0;
end
len = length(JuiceTimes);
if len == 0
    m = 0;
end

for m = 1:len
    TrialPreStruct(n+m).type = 'j';
    TrialPreStruct(n+m).time = JuiceTimes(m);
end

len = length(JuiceTimes);
if len == 0
    m = 0;
end

TrialPreStruct = SortStructAscend(TrialPreStruct, 'time');
c = 1;
k = 1;
     if ([TrialPreStruct(k+1).time] - [TrialPreStruct(k).time] > 5)
         if TrialPreStruct(k).type == 'j'
                          'hello'
             TrialStruct(c).TrialType = 'j'
             TrialStruct(c).ToneTime = NaN
             TrialStruct(c).JuiceTime = TrialPreStruct(k).time
             c = c + 1;
         end
         if TrialPreStruct(k).type == 't'  

             TrialStruct(c).TrialType = 't'
             TrialStruct(c).ToneTime = TrialPreStruct(k).time
             TrialStruct(c).JuiceTime = NaN
             c = c + 1;
         end
     else
         if TrialPreStruct(k).type == 't' && TrialPreStruct(k+1).type == 'j'
              TrialStruct(c).TrialType = 'b';
              TrialStruct(c).ToneTime = TrialPreStruct(k).time;
             TrialStruct(c).JuiceTime = TrialPreStruct(k+1).time;
             c = c + 1;
             k = 2;
         end
     end

 for k = k:(m+n-1)
     if TrialPreStruct(k).type == 't'
         if TrialPreStruct(k+1).type == 't'
             TrialStruct(c).TrialType = 't';
             TrialStruct(c).ToneTime = TrialPreStruct(k).time;
             TrialStruct(c).JuiceTime = NaN;
             c = c + 1;
         end
         if TrialPreStruct(k+1).type == 'j' && ([TrialPreStruct(k+1).time] - [TrialPreStruct(k).time] > 5)
              TrialStruct(c).TrialType = 't';
             TrialStruct(c).ToneTime = TrialPreStruct(k).time;
             TrialStruct(c).JuiceTime = NaN;
             c = c + 1;
         end
         if TrialPreStruct(k+1).type == 'j' && ([TrialPreStruct(k+1).time] - [TrialPreStruct(k).time] < 5)
             TrialStruct(c).TrialType = 'b';                                        %if the last trial was tone after juice, it would be captured here.
             TrialStruct(c).ToneTime = TrialPreStruct(k).time;
             TrialStruct(c).JuiceTime = TrialPreStruct(k+1).time;
             c = c + 1;
             %k = k + 1;
         end
     end
     if k >1
     if TrialPreStruct(k).type == 'j' & TrialPreStruct(k-1).type == 'j'
            TrialStruct(c).TrialType = 'j';
             TrialStruct(c).ToneTime = NaN;
             TrialStruct(c).JuiceTime = TrialPreStruct(k).time;
             c = c + 1;
     end
     if TrialPreStruct(k).type == 'j' & TrialPreStruct(k-1).type == 't'
         if([TrialPreStruct(k).time] - [TrialPreStruct(k-1).time] > 5) %if trial is juice after tone, it is skipped here
            TrialStruct(c).TrialType = 'j';
             TrialStruct(c).ToneTime = NaN;
             TrialStruct(c).JuiceTime = TrialPreStruct(k).time;
             c = c + 1;
         end   
     end
     end
     
 end

k =(m+n);               %if the last trial is tone or juice alone, capture it here
      if TrialPreStruct(k).type == 't'
             TrialStruct(c).TrialType = 't';
             TrialStruct(c).ToneTime = TrialPreStruct(k).time;
             TrialStruct(c).JuiceTime = NaN;
      end
      if TrialPreStruct(k).type == 'j' & TrialPreStruct(k-1).type == 'j'
            TrialStruct(c).TrialType = 'j';
             TrialStruct(c).ToneTime = NaN;
             TrialStruct(c).JuiceTime = TrialPreStruct(k).time;
     end
     if TrialPreStruct(k).type == 'j' & TrialPreStruct(k-1).type == 't'
         if([TrialPreStruct(k).time] - [TrialPreStruct(k-1).time] > 5) %if trial is juice after tone, it is skipped here
            TrialStruct(c).TrialType = 'j';
             TrialStruct(c).ToneTime = NaN;
             TrialStruct(c).JuiceTime = TrialPreStruct(k).time;
         end   
     end
      
J = [TrialStruct.TrialType].' == 'j';
T = [TrialStruct.TrialType].' == 't';
B = [TrialStruct.TrialType].' == 'b';

Temp = [TrialStruct.JuiceTime].';
JuiceAlone = Temp(J);
JuiceAfterTone = Temp(B);

Temp = [TrialStruct.ToneTime].';
ToneAlone = Temp(T);
ToneBeforeJuice = Temp(B);

delay = JuiceAfterTone - ToneBeforeJuice;
delay = mode(round(delay,5))

d = 1;
for n = 1:length(TrialStruct)
    TrialStruct(n).FictiveJuice = TrialStruct(n).JuiceTime;
    if isnan(TrialStruct(n).FictiveJuice)
        TrialStruct(n).FictiveJuice = TrialStruct(n).ToneTime + delay;
        FictiveJuice(d) = TrialStruct(n).ToneTime + delay;
        d = d + 1;
    end
end
if d == 1
    FictiveJuice = NaN;
end
   
if TrialStruct(1).FictiveJuice == TrialStruct(1).FictiveJuice
    TrialStruct(1) = [];
end
end