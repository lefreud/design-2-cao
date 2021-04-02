close all
clear all
clc

%% Paramètres physiques
l = 0.0735;        % Largeur
h = 1.59e-3;     % Hauteur
L = 0.27;     % Longueur
J = l*h^3/12;    % Moment d'aire
E = 16.95e9;      % Module de Young
dens = 1909.91343;     % Densité Kg/m^3
mu =  dens*l*h; % Masse linéique kg/m = rho x cross section
gamma=0.15; %frottement

%% Inputs
masse = 10; % En grammes
g = 9.81; % Accélération gravitationnelle
poids = masse/1000 * g; %F=mg
force_em = 0.5; %Amplitude de la force EM de l'actionneur

%% Discrétisation
nx = 20; % Nb d'éléments spatiaux
temps_simul = 5; %temps de la simulation en s
dt = 0.7e-4; % incrément temporel (delta t)
nt = round(temps_simul/dt);       % Nb d'éléments temporels (temps total divisé par temps de 1 incrément
dx =   L/(nx-1); % incrément spatial (delta x))
x  = (0:dx:L);     % vecteur spatial (de -dx à L+dx avec un pas de dx)

%% Stabilité de la simulation
stabilite = E*J*dt^2/(mu*dx^4); %doit être inférieur à 0.25 pour que ca soit stable

if(stabilite > 0.25)
       warning('La simulation ne sera pas stable !')
end

%% Arrays
w=zeros(1,nx); % Aucune déformation initiale (w=0 pour tous x)
force_actionneur = zeros(1, nx); % On créé un vecteur force à zéro pour chaque x (il contiendra la force du à l'actionneur)
force_actionneur(13) = force_em; % 13=élément correspondant à environ à x=16.5 cm (position de l'actionneur)
force_grav = zeros(1, nx); % On créé un vecteur force à zéro pour chaque x (il contiendra la force due au poids de la masse)
force_grav(13) = poids; % 13=élément correspondant à environ à x=16.5 cm (position de la masse)
w_old = w;            % un pas dans le passé (les termes en n-1 dans différence finie)
w_new = zeros(1,nx); % ce qui sera calculé à chaque tour, zeros(1, nx): array de 1 x nx
point_capteur = zeros(1, nt+1); % array contenant déflexion en fonction du temps


% Précalcul d'une constante pour alléger la boucle
constant = 1/((mu/dt^2)+(gamma/(2*dt)));

for n=0:nt
    
    w_new = zeros(1,nx);
    
    i = 3:nx-2; % à partir de 3 comme ça 1 et 2 reste à 0 toujours
    
    w_new(i) = constant * ((mu/dt^2)*(2*w(i)-w_old(i)) + gamma*w_old(i)/(2*dt) - ...
        (E*J/dx^4)*(w(i+2) - 4*w(i+1) + 6*w(i) - 4*w(i-1) + w(i-2)) + (force_actionneur(i)-force_grav(i))/dx);
 
    w_new(1:2) = 0; % Clampé à zero, position et dérivée nulle des deux premiers éléments
   
   
    w_new(end-1) = 2*w_new(end-2)-w_new(end-3);    % Libre au bout dérivées 2e et 3e nulles
    w_new(end) = 2*w_new(end-1)-w_new(end-2);
    
    
    w_old = w; 
    w = w_new;
    
    point_capteur(n+1) = w(18); % 18=élément correspondant à environ à x=24.5 cm (position du capteur)
   
end

temps=[0:dt:temps_simul+dt];
plot(temps, point_capteur);
xlabel('Temps [s]');
ylabel('Déflexion à x = 24.5 cm [m]');
grid;
