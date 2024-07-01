clear;clc;clf

x_length = 500; % Angstrom, from dump file
y_length = 48; % Angstrom, from dump file
z_length = 3.35; % Angstrom, thickness of single layer graphene from literature
timestep = 0.0005; % ps

%% -------------------Temperature Profile-------------------------------
filename = "temp_equ.dat";
delimiterIn = ' ';
headerlinesIn = 4;
imported = importdata(filename,delimiterIn,headerlinesIn);
temp = imported.data;

position = temp(10:90,2); % Dimensionless
real_position = position * x_length; % Angstrom
temperature = temp(10:90,4); % Kelvin
figure(1)
ylim([200 400])
hold on
plot(temp(:,2),temp(:,4),".")

%% -------------------Temperature Gradient-------------------------------
fTx = polyfit(real_position,temperature,1);
dTdx = fTx(1); % Temperature gradient in K A-1
fit_x = [0 1];
fit_y = polyval(fTx,fit_x * x_length);
plot(fit_x,fit_y)
legend("Experimental", "Fitted Line")
title("Temperature Profile for 5 ns")
xlabel("x")
ylabel("Temperature (K)")
hold off

%% -------------------Heat Flux-------------------------------
filename = "Ener_equ.dat";
delimiterIn = ' ';
headerlinesIn = 1;
imported = importdata(filename,delimiterIn,headerlinesIn);
Heat = imported.data;

time = Heat(:,1) * timestep; % ps
Ehot = Heat(:,2); % eV
Ecold = Heat(:,3); % eV
figure(2)
hold on
plot(time/1000,Ehot,time/1000,Ecold)
legend("Hot thermostat","Cold thermostat")
title("Energy Produced by Thermostats")
xlabel("Time (ns)")
ylabel("Energy (eV)")
hold off

for i = 1:length(Ehot)
    E(i) = (abs(Ehot(i)) + abs(Ecold(i)))/2;
end

fEt = polyfit(time,E,1);
dEdt = fEt(1); % eV per ps
flux = dEdt / (y_length * z_length); % eV ps-1 A-2

%% -------------------Thermal Conductivity-------------------------------
kappa = - flux / dTdx; % eV ps-1 A-1 K-1
eV2J = 1.602e-19;
ps2s = 1e-12;
A2m = 1e-10;
kappa = kappa * eV2J / ps2s / A2m % J s-1 m-1 K-1