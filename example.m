% A few examples on how to use the Point and TestParticle classes

%% make points using the different constructors (the properties appear in command window)

p1 = particle.Point % default point at (0,0,0);

%% 

p2 = particle.Point(1,2,3)

%% 

p3 = particle.Point('rand')

%% use dot notation to get properties, change them, or call some action on the object

p2.x

p1.y=2;

p3.move(1,2,-2); p3

%% calculate the distances

d12 = p1.dist(p2);
d23 = p2.dist(p3);
d31 = p3.dist(p1);

disp(['1->2: ' num2str(d12) ' | 2->3: ' num2str(d23) ' | 3->1: ' num2str(d31)]);

%% calculate the angle between two points (in degrees)

ang = rad2deg(p1.phiTo(p3))

%% put the points in a vector of points and plot them

p4 = Point('rand');

p = [p1 p2 p3 p4];

p.plot2D; 


%% generate some test particles  (the properties appear in command window)

dp1 = particle.TestParticle

dp2 = particle.TestParticle('rand','rand')

%% use a Static function to make a bunch of rand particles

dp = particle.TestParticle.makeRandomParticles(20); % notice this is a static function that doesn't need any particle to be called on. 

dp.plot2D; % calls the Point class plotting tools. 

%% move all particles a short distance

dp.moveAll(0.5);

dp.plot2D;

%% run a simple simulation

dp = particle.TestParticle.makeRandomParticles(20); % notice this is a static function that doesn't need any particle to be called on. 

for ii=1:100
    
    dp.moveAll(1);
    dp.plot2D;
    xlabel(['ii= ' num2str(ii)]);
    drawnow;
    
end

%% put a planet with gravity in the middle

P = particle.Planet; % supports only default constructor

P.makeParticles;

P.run;





