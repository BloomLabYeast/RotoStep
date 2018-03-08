function [dist] = distance_between_3D_chromoshake(a, b, c)

% finds the 3D distance using the equation a^2 + b^2 + c^2 = d^2
dist = sqrt((a(1) - a(2))^2 + (b(1) - b(2))^2 + (c(1) - c(2))^2);