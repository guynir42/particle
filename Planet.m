classdef Planet < particle.TestParticle
   
    properties 
        
        % some details about this object
        name = 'Ceres';
        mass = 9.4e20; % in kg
        radius = 0.47; % in units of 10^6 meters
        
        particle_list@particle.TestParticle; % a list of particles in the gravitational field of this planet
        
    end
    
    properties(Hidden=true)
       
        % maybe add graphical properties for plotting? colors etc...
        
    end
    
    methods % constructor
        
        function obj = Planet
            % This should look similar to the constructor for TestParticle
            % It becomes increasingly complicated to get different optional
            % constructor arguments into the inheritance chain. 
            % for now, we've only implemented a default constructor
            % even that is actually not required (if we don't do anything
            % in this block). The TestParticle constructor will be called
            % without arguments as well. 
        end
        
    end
    
    methods % getters
        
    end
    
    methods % setters
        
    end
    
    methods % actions
       
        function makeParticles(obj, number)

            if nargin<2 || isempty(number)
                number = 20;
            end
            
            obj.particle_list = particle.TestParticle.makeRandomParticles(20);

        end
        
        function run(obj, num_steps, time)
            
            if nargin<2 || isempty(num_steps)
                num_steps = 100;
            end
            
            if nargin<3 || isempty(time)
                time = 1;
            end
            
            for ii = 1:num_steps
                obj.step(time);
                obj.plot2D;
                drawnow;
            end
            
        end
        
        function step(obj, time)
            
            if nargin<2 || isempty(time)
                time = 1;
            end
            
            obj.accelerateParticles(obj.particle_list, time); % note that we don't have to return the list, the function runs on each member (that are handles)
            obj.moveParticles(obj.particle_list, time);
            
            obj.particle_list = obj.removeCrahsedParticles(obj.particle_list); % now we must return the new, adjusted vector, and put it instead of the old list. 
            obj.particle_list = obj.removeDistantParticles(obj.particle_list);
            
        end
        
        function accelerateParticles(obj, particle_list, time)
            
            if nargin<2 || isempty(particle_list)
                particle_list = obj.particle_list; % default is to use its own list, but can be given some other list to accelerate
            end
            
            if nargin<3 || isempty(time)
                time = 1;
            end
            
            for ii = 1:length(particle_list)
                
                d = dist(obj, particle_list(ii));
                dir = getDirectionVector(obj, particle_list(ii));
                a = -particle.Planet.G.*obj.mass./d.^2.*dir; % GM/r^2*r_hat
                
                particle_list(ii).accelerate(a.*time);
                
            end
                        
        end
        
        function moveParticles(obj, particle_list, time)
            
            if nargin<2 || isempty(particle_list)
                particle_list = obj.particle_list; % default is to use its own list, but can be given some other list to accelerate
            end
            
            if nargin<3 || isempty(time)
                time = 1;
            end
            
            moveAll(particle_list, time); 
            
        end
        
        function new_list  = removeCrahsedParticles(obj, particle_list) % takes out of the list any particles that collided with the planet
            
            if nargin<2 || isempty(particle_list)
                particle_list = obj.particle_list; % default is to use its own list, but can be given some other list to accelerate
            end
            
            for ii = 1:length(particle_list)
                idx(ii) = dist(obj, particle_list(ii))<obj.radius;
            end
            
            new_list = particle_list(~idx);
                        
        end
        
        function new_list = removeDistantParticles(obj, particle_list) % takes out of the list any particles that have wandered too far
         
            if nargin<2 || isempty(particle_list)
                particle_list = obj.particle_list; % default is to use its own list, but can be given some other list to accelerate
            end
            
            idx = [];
            for ii = 1:length(particle_list)
                idx(ii) = dist(obj, particle_list(ii))>100;
            end
            
            new_list = particle_list(~idx);
            
        end
            
    end
    
    methods % plotting tools
       
        function plot2D(obj)
            
            plot2D@particle.Point(obj, 'r+'); % note we are calling the overriden function of the base class
            viscircles([obj.x,obj.y],obj.radius, 'Color', 'red'); 
            hold on;
            plot2D(obj.particle_list);
            hold off;
            axis square;
            
        end
        
    end
    
    methods(Static=true)
       
        function val = G
            
             val = 6.67e-11; % static const value in the form of a static function
             val = val./1e18; % convert to units of 1e6 meters
             val = val.*1e6; % convert to units of 1e3 seconds
             
        end
        
    end
    
end