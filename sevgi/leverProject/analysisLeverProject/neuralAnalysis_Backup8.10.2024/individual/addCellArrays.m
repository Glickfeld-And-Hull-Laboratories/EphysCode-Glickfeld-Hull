function [pair00_RR_arr,pair01_RR_arr, pair10_RR_arr, pair11_RR_arr, pair00_RT_arr, pair01_RT_arr, pair10_RT_arr, pair11_RT_arr, ...
                pair00_TR_arr, pair01_TR_arr, pair10_TR_arr, pair11_TR_arr, pair00_TT_arr, pair01_TT_arr, pair10_TT_arr, pair11_TT_arr] = ...
                addCellArrays(pair00_RR_arr,pair01_RR_arr, pair10_RR_arr, pair11_RR_arr, pair00_RT_arr, pair01_RT_arr, pair10_RT_arr, pair11_RT_arr, ...
                pair00_TR_arr, pair01_TR_arr, pair10_TR_arr, pair11_TR_arr, pair00_TT_arr, pair01_TT_arr, pair10_TT_arr, pair11_TT_arr, ...
                pair00_RR, pair01_RR, pair10_RR, pair11_RR, pair00_RT, pair01_RT, pair10_RT, pair11_RT, ...
                pair00_TR, pair01_TR, pair10_TR, pair11_TR, pair00_TT, pair01_TT, pair10_TT, pair11_TT)


            pair00_RR_arr = [pair00_RR_arr; pair00_RR]; % NoCS(0) in trial n around Release(R) timing and NoCS(0) in trial n+1 around Release(R) timing
            pair01_RR_arr = [pair01_RR_arr; pair01_RR];
            pair10_RR_arr = [pair10_RR_arr; pair10_RR];
            pair11_RR_arr = [pair11_RR_arr; pair11_RR];

            pair00_RT_arr = [pair00_RT_arr; pair00_RT]; % NoCS(0) in trial n around Release(R) timing and NoCS(0) in trial n+1 around Target stim change(T) timing
            pair01_RT_arr = [pair01_RT_arr; pair01_RT];
            pair10_RT_arr = [pair10_RT_arr; pair10_RT];
            pair11_RT_arr = [pair11_RT_arr; pair11_RT];

            pair00_TR_arr = [pair00_TR_arr; pair00_TR]; % NoCS(0) in trial n around Target stim change(T) timing and NoCS(0) in trial n+1 around Release(R) timing
            pair01_TR_arr = [pair01_TR_arr; pair01_TR];
            pair10_TR_arr = [pair10_TR_arr; pair10_TR];
            pair11_TR_arr = [pair11_TR_arr; pair11_TR];

            pair00_TT_arr = [pair00_TT_arr; pair00_TT]; % NoCS(0) in trial n around Target stim change(T) timing and NoCS(0) in trial n+1 around Target stim change(T) timing
            pair01_TT_arr = [pair01_TT_arr; pair01_TT];
            pair10_TT_arr = [pair10_TT_arr; pair10_TT];
            pair11_TT_arr = [pair11_TT_arr; pair11_TT];

end