% Read the data
points = readtable('Graph_251343797.txt');


N = 12; % I added one node to ensure full connectivity

% Plot the nodes as solid dots
figure; % Creates a new figure window
plot(points.Var1, points.Var2, 'bo', 'MarkerFaceColor', 'b');
title('Wireless Sensor Network');
xlim([0 1]);
ylim([0 1]);
hold on; 

% This is the communications radius
RC = 0.4;

% Loop through all nodes to draw communication lines
for p = 1:N
    for q = p+1:N
        % Calculate distance between two nodes
        d = sqrt((points.Var1(p) - points.Var1(q))^2 + (points.Var2(p) - points.Var2(q))^2);
        % If distance is less than communications radius, draw a line
        if d < RC
            plot([points.Var1(p), points.Var1(q)], [points.Var2(p), points.Var2(q)], 'r-');
        end
    end
end

% The sensing radius
RS = 0.4;
% Loop through all nodes to draw sensor ranges with semi-transparent colors
for p = 1:N
    rectangle('Position', [points.Var1(p)-RS, points.Var2(p)-RS, 2*RS, 2*RS], 'Curvature', [1, 1], 'EdgeColor', 'none', 'FaceColor', [0, 1, 0, 0.2]);
end


% Plot Voronoi Tessellation Diagram
figure;
VT=voronoi(points.Var1, points.Var2);
set(VT(2:end),'linestyle','--','Color', 'red')
title('Voronoi Tessellation Diagram of Sensor Nodes');

figure;
hold on;
% Comput Delaunay triangulation
tri = delaunayTriangulation(points.Var1, points.Var2);
% Plot the triangulation
triplot(tri, 'LineStyle', '--', 'Color', 'red'); 
% Scatter plot for points
scatter(points.Var1, points.Var2, 'filled', 'MarkerFaceColor', 'blue');
title('Delaunay Triangulation Diagram of Sensor Nodes');

