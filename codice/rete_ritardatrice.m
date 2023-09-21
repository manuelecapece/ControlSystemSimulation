function [Ctr] = rete_ritardatrice(M,phi,om)
%% Restituisce la fdt della rete

%M in decibel
%phi in gradi
%om in rad\sec

M = 10^(M/20);       %coverte M in valore naturale
phi = phi*pi/180;    %coverte phi in radianti

tau = 1/om * (M - sqrt(1+tan(phi)^2)) / (M*tan(phi));
alfa = 1/(om*tau) * sqrt((1+(om*tau)^2)*M^2-1);

Ctr = tf([alfa * tau 1],[tau 1]);