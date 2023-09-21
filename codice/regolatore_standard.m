function [C] = regolatore_standard(M, phi, wt, a, ideale)
%M in decibel
%phi in gradi

M = 10^(M/20);
s = tf('s');

if a==1
    a = 'PI';
elseif a == 2
    a = 'PD';
elseif a == 3
    a = 'PID';
end

switch a
    case 'PI'
        tau_i = tand(phi+90)/wt;
        k_i = M*wt / (sqrt(1+wt^2 * tau_i^2));
        C = k_i/s*(1+s*tau_i);
    case 'PD'
        tau_d = tand(phi)/wt;
        k_p = M / (sqrt(1+wt^2 * tau_d^2));
        if ideale 
            C = k_p *(1+s*tau_d);
        else
            C = k_p *(1+s*tau_d)/(1+s*0.0001*tau_d);
        end
    case 'PID'
        tau_d = (-sqrt(wt^2*((tand(phi+90))^2+1))-wt)/(2*wt^2*tand(phi+90));
        k_i = (M*wt) / sqrt((1-4*wt^2*tau_d^2)^2+16*wt^2*tau_d^2);
        if ideale 
            C = k_i / s * (1+4*s*tau_d+4*tau_d^2*s^2);
        else
            C =  k_i / s * (1+4*s*tau_d+4*tau_d^2*s^2)/(1+s*0.0001*tau_d);
        end
end