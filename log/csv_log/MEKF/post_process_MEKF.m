%% Post process MATLAB script for navigation code
clc,close all,clear all
%%read data
state_data = csvread('state_data.csv');
kalman_state_data = csvread('kalman_state_data.csv');

kalman_covariance_diagonal_data = csvread('kalman_covariance_diagonal.csv');


%% plot trajectory
title("Simulation trajectory visualisation")
axis equal
plot3(state_data(:,2),state_data(:,3),state_data(:,4))
hold on
plot3(kalman_state_data(:,2),kalman_state_data(:,3),kalman_state_data(:,4))
legend("Simulated trajectory","Kalman Trajectory")

%% error plots
% time vectir
tt_kal = kalman_state_data(:,1);

% interpolate messages in a common time vector
interp_state_x = interp1(state_data(:,1),state_data(:,2),tt_kal);
interp_state_y = interp1(state_data(:,1),state_data(:,3),tt_kal);
interp_state_z = interp1(state_data(:,1),state_data(:,4),tt_kal);

interp_state_vel_x = interp1(state_data(:,1),state_data(:,5),tt_kal);
interp_state_vel_y = interp1(state_data(:,1),state_data(:,6),tt_kal);
interp_state_vel_z = interp1(state_data(:,1),state_data(:,7),tt_kal);

interp_state_mass = interp1(state_data(:,1),state_data(:,15),tt_kal);

% calculate errors
err_x = kalman_state_data(:,2)-interp_state_x;
err_y = kalman_state_data(:,3)-interp_state_y;
err_z = kalman_state_data(:,4)-interp_state_z;

err_vel_x = kalman_state_data(:,5)-interp_state_vel_x;
err_vel_y = kalman_state_data(:,6)-interp_state_vel_y;
err_vel_z = kalman_state_data(:,7)-interp_state_vel_z;

err_mass = kalman_state_data(:,15)-interp_state_mass;


%%  error Plot config
figure
tiledlayout(4,3)


Z_confidance = 2.576; % 99% interval

%% err_x
nexttile
hold on
plot(tt_kal,err_x);
plot(tt_kal,Z_confidance*sqrt(kalman_covariance_diagonal_data(:,2)),'red');
plot(tt_kal,-Z_confidance*sqrt(kalman_covariance_diagonal_data(:,2)),'red');
xlabel("time [s]")
ylabel("error [m]")
title("Kalman error in position x")

%% err_y
nexttile
hold on
plot(tt_kal,err_y);
title("Kalman error in position y")
plot(tt_kal,Z_confidance*sqrt(kalman_covariance_diagonal_data(:,3)),'red');
plot(tt_kal,-Z_confidance*sqrt(kalman_covariance_diagonal_data(:,3)),'red');
xlabel("time [s]")
ylabel("error [m]")


%% err_z
nexttile
hold on
title("Kalman error in position z")
plot(tt_kal,err_z);
plot(tt_kal,Z_confidance*sqrt(kalman_covariance_diagonal_data(:,4)),'red');
plot(tt_kal,-Z_confidance*sqrt(kalman_covariance_diagonal_data(:,4)),'red');
xlabel("time [s]")
ylabel("error [m]")

%% err_vel_x
nexttile
hold on
plot(tt_kal,err_vel_x);
title("Kalman error in velocity x (Inertial frame)")
plot(tt_kal,Z_confidance*sqrt(kalman_covariance_diagonal_data(:,5)),'red');
plot(tt_kal,-Z_confidance*sqrt(kalman_covariance_diagonal_data(:,5)),'red');
xlabel("time [s]")
ylabel("error [m/s]")

%% err_vel_y
nexttile
hold on
plot(tt_kal,err_vel_y);
title("Kalman error in velocity y (Inertial frame)")
plot(tt_kal,Z_confidance*sqrt(kalman_covariance_diagonal_data(:,6)),'red');
plot(tt_kal,-Z_confidance*sqrt(kalman_covariance_diagonal_data(:,6)),'red');
xlabel("time [s]")
ylabel("error [m/s]")

%% err_vel_z
nexttile
hold on
plot(tt_kal,err_vel_z);
plot(tt_kal,Z_confidance*sqrt(kalman_covariance_diagonal_data(:,7)),'red');
plot(tt_kal,-Z_confidance*sqrt(kalman_covariance_diagonal_data(:,7)),'red');
title("Kalman error in velocity z (Inertial frame)")
xlabel("time [s]")
ylabel("error [m/s]")

%% attitude

%get quaternion data from state
quat_kal = [kalman_state_data(:,11),kalman_state_data(:,8),kalman_state_data(:,9),kalman_state_data(:,10)]; % [qw,qx,qy,qz]

interp_qw = interp1(state_data(:,1),state_data(:,11),tt_kal);
interp_qx = interp1(state_data(:,1),state_data(:,8),tt_kal);
interp_qy = interp1(state_data(:,1),state_data(:,9),tt_kal);
interp_qz = interp1(state_data(:,1),state_data(:,10),tt_kal);
quat_sim = [interp_qw,interp_qx,interp_qy,interp_qz];% [qw,qx,qy,qz]

%transform to euler angles

rod_sim = quat2rod(quat_sim);
rod_kal= quat2rod(quat_kal);

err_rod = (rod_kal-rod_sim);

nexttile
hold on
plot(tt_kal,err_rod(:,1));
title("error in alpha_x ")
xlabel("time [s]")
ylabel("error [deg]")
plot(tt_kal,Z_confidance*sqrt(kalman_covariance_diagonal_data(:,8)),'red');
plot(tt_kal,-Z_confidance*sqrt(kalman_covariance_diagonal_data(:,8)),'red');

nexttile
hold on
plot(tt_kal,err_rod(:,2));
title("error in alpha_y ")
xlabel("time [s]")
ylabel("error [deg]")

plot(tt_kal,Z_confidance*sqrt(kalman_covariance_diagonal_data(:,9)),'red');
plot(tt_kal,-Z_confidance*sqrt(kalman_covariance_diagonal_data(:,9)),'red');

nexttile
hold on
plot(tt_kal,err_rod(:,3));
title("error in alpha_z")
xlabel("time [s]")
ylabel("error [deg]")
plot(tt_kal(1:end-3),Z_confidance*sqrt(kalman_covariance_diagonal_data(1:end-3,10)),'red');
plot(tt_kal(1:end-3),-Z_confidance*sqrt(kalman_covariance_diagonal_data(1:end-3,10)),'red');


%% err_mass
% nexttile
% hold on
% plot(tt_kal,err_mass);
% plot(tt_kal,Z_confidance*sqrt(kalman_covariance_diagonal_data(:,14)),'red');
% plot(tt_kal,-Z_confidance*sqrt(kalman_covariance_diagonal_data(:,14)),'red');
% title("Kalman error in mass")
% xlabel("time [s]")
% ylabel("error [Kg]")

%% Plots
figure
title("Rodrigues parameters")
hold on
plot(tt_kal,rod_sim(:,1));
plot(tt_kal,rod_sim(:,2));
plot(tt_kal,rod_sim(:,3));
plot(tt_kal,rod_kal(:,1));
plot(tt_kal,rod_kal(:,2));
plot(tt_kal,rod_kal(:,3));
legend("\alpha_{x,sim}","\alpha_{y,sim}","\alpha_{z,sim}","\alpha_{x,kal}","\alpha_{y,kal}","\alpha_{z,kal}")







