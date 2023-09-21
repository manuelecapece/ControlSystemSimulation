%% Codice progetto PSC

clc;
clear all;
close all;

s = tf('s');
P = (20 * exp(-0.1 * s)) / ((1 + s) * (s^2 + 2*s + 4))
H = 2
Cr = 10 / s 
Fr = P*Cr*H

%Pulsazione di attraversamento e margine di fase desiderati
wt = 3 
mphi = 40

nichols(Fr)
[M,phi] = bode(Fr,wt);
Mdb = db(M);
fprintf('Modulo di Fr in corrispondenza di wt : %2f.\n', Mdb)
fprintf('Fase di Fr in corrispondenza di wt : %2f.\n',phi)

%% PROGETTAZIONE CON RETI CORRETTRICI

%Attenuazione desiderata
ATT_D = 0 - Mdb
%Anticipo desiderato
ANT_D = -180+mphi-phi

%Progettazione sezione anticipatrice Cta
%Uso Cta in cascata per raggiungere l'anticipo desiderato
fprintf('Sezione anticipatrice\n')

alpha_a = 1/20;
w_tau = 2;
tau_a = w_tau/wt;

Cta = (1+s*tau_a)/(1+s*tau_a*alpha_a)
[amp_a,ant_a] = bode(Cta,wt);
amp_a_db = db(amp_a);
fprintf('Amplificazione in db : %2f.\n', amp_a_db)
fprintf('Anticipo : %2f.\n',ant_a)

%Progettazione sezione ritardatrice Ctr
fprintf('Sezione ritardatrice\n')

rit_r = ANT_D - ant_a * 3
att_r = ATT_D - amp_a_db * 3

Ctr = rete_ritardatrice(att_r,rit_r,wt)
[att_r,rit_r] = bode(Ctr,wt);
att_r_db = db(att_r);
fprintf('Attenuazione in db : %2f.\n', db(att_r_db))
fprintf('Ritardo : %2f.\n',rit_r)

%Progettazione della Sella Ct

Ct = (Cta * Cta * Cta) * Ctr;
C = Cr * Ct
F = C * P * H;
nichols(Fr,'--b',F, 'r')
legend('Fr', 'F', 'Location', 'northwest')
disp('Specifiche soddisfatte!')

%% Verifica risposta di W nel dominio del tempo
W = minreal(C * P / (1 + F));
t = 0:0.001:40;

%Controllo comportamento a fronte di una rampa di ampiezza 2
u2 = t*2;
figure;
sgtitle('Risposta di W - Rete a Sella')
y = lsim(W,u2,t);
subplot(2, 2, 1);
plot(t,y,'LineWidth', 1.5);
hold on;
plot(t,u2,'LineWidth', 1.5)
grid on;
title('Amplitude 2 Ramp response');
xlabel('Time(Seconds)');
ylabel('Amplitude');
legend('W response', '2*ramp', 'Location', 'northwest')
%Verifica dell'errore 
yd = (u2/2)-0.01;
e = yd-y';
fprintf('Modulo di CregPID in corrispondenza di wt : %2f.\n', Mdb)
fprintf('Fase di CregPID in corrispondenza di wt : %2f.\n',phi)
subplot(2, 2, 3);
plot(t,e,'LineWidth', 1.5)
grid on;
title('Amplitude 2 Ramp response error');
xlabel('Time(Seconds)');
ylabel('Error');

%Risposta a gradino con pendenza 2
opt = RespConfig("Amplitude",2);
subplot(2, 2, 2);
y = step(W,t,opt);
plot(t,y,'LineWidth', 1.5)
grid on;
title('Amplitude 2 Step response');
xlabel('Time(Seconds)');
ylabel('Amplitude');

%Controllo comportamento a fronte di ingresso nullo e disturbo a gradino
%carico il risultato della simulazione effettuata su simulink
load("simCaso2.mat")
%plot risultato simulazione ingresso nullo e disturbo a gradino
subplot(2, 2, 4);
plot(out.y,'LineWidth', 1.5)
grid on;
title('Response of r=0 and d = 3*step');
ylabel('Amplitude');

%% PROGETTAZIONE CON REGOLATORI STANDARD
%Soddisfazione delle sole specifiche in transitorio

F_PID = P * H
[M,phi] = bode(F_PID,wt);
Mdb = db(M);
ATT_D = 0 - Mdb
ANT_D = -180+mphi-phi

[CregPID] = regolatore_standard(ATT_D, ANT_D, wt, 3, false)
[M,phi] = bode(CregPID,wt);
Mdb = db(M);
fprintf('Modulo di CregPID in corrispondenza di wt : %2f.\n', Mdb)
fprintf('Fase di CregPID in corrispondenza di wt : %2f.\n',phi)

figure;
F_PID = CregPID * P * H;

nichols(Fr,'--b',F,'r',F_PID, 'g')
legend('Fr', 'F', 'F_{PID}', 'Location', 'northwest')
disp('Specifiche soddisfatte!')
