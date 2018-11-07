classdef TestParticle < particle.Point % also inherits handle from it
% TestParticle is a subclass of Point, so it has x,y,z coordinates, in 
% addition it keeps track of its velocity: vx,vy,vz. 
% Can be told to propagate at constant speed or get acceleration using the 
% function accelerate(obj, ax, ay, az). 
% Use obj = TestParticle([pos_vec], [velocity_vec]) to give position and
% velocity. Replace any vector with 'rand' to get random position or
% velocity in the range [-10,10] and [-1,1]. 

    properties 
       
        % will have x,y,z coordinates from Point, then adds velocities
        v_x = 0;
        v_y = 0;
        v_z = 0;
        
    end
       
    methods % constructor
       
        function obj = TestParticle(varargin)
            
            if isempty(varargin) % default constructor
                vx=[];
                vy=[];
                vz=[];                
                point_args = {}; % must store arguments to pass to base class constructor       
            elseif isa(varargin{1}, 'particle.TestParticle') % copy constructor
                
                vx = varargin{1}.v_x;
                vy = varargin{1}.v_y;
                vz = varargin{1}.v_z;
                
                point_args{1} = [varargin{1}.x varargin{1}.y varargin{1}.z];
                
            elseif length(varargin)==2 && length(varargin{1})==3 && length(varargin{2})==3 % this case assumes you mean position and then velocity
                                
                point_args{1} = varargin{1};
                
                if isnumeric(varargin{2})
                
                    vec = varargin{2}; % this should be velocity vector
                
                    vx = vec(1);
                    if length(vec)>=2, vy = vec(2); end
                    if length(vec)>=3, vz = vec(3); end
                    
                end
                
            elseif length(varargin)==2 && ischar(varargin{2})
                
                point_args{1} = varargin{1};
                
                if strcmpi(varargin{2}, 'rand')
                        vx = (rand-0.5).*2.*particle.TestParticle.range; 
                        vy = (rand-0.5).*2.*particle.TestParticle.range; 
                        vz = (rand-0.5).*2.*particle.TestParticle.range; 
                end
                        
            else % just pass any arguments to point class
                
                vx = [];
                vy = [];
                vz = [];
                point_args = varargin;
                
            end
            
            % must finish parsing the inputs without touching the object
            % itself, until you call the base constructor: 
            obj = obj@particle.Point(point_args{:}); % this cannot be conditional! 
            
            % now we've constructed the object, can fill out the properties
            if ~isempty(vx), obj.v_x = vx; end
            if ~isempty(vy), obj.v_y = vy; end
            if ~isempty(vz), obj.v_z = vz; end
            
        end
        
    end
    
    methods % getters
       
        function vec = getVelocityXYZ(obj)
            
            vec = [obj.v_x obj.v_y obj.v_z];
            
        end
        
    end
    
    methods % setters
        
        function setVelocityXYZ(obj, varargin)
           
            vec = particle.Point.inputToVector(varargin{:});
            
            obj.v_x = vec(1);
            obj.v_y = vec(2);
            obj.v_z = vec(3);
            
            
        end
        
    end
    
    methods % actions
        
        function accelerate(obj, varargin)
           
            vec = particle.Point.inputToVector(varargin{:});
            
            obj.setVelocityXYZ(obj.getVelocityXYZ + vec);
            
        end

        function accelerateDirection(obj, amount, theta, phi)
           
            ax = amount.*cos(phi).*sin(theta);
            ay = amount.*sin(phi).*sin(theta);
            az = amount.*cos(theta);
            
            obj.accelerate(ax,ay,az); % use existing method to input acceleration (any other checks made through that function)
            
        end
        
        function moveAll(obj, time) % makes all particles in the vector 'obj' move according to their velocity (and input time)
            
            if nargin<2 || isempty(time) % check for default argument...
                time = 0.001;
            end
            
            for ii = 1:length(obj)
               
                obj(ii).move([obj(ii).v_x, obj(ii).v_y, obj(ii).v_z].*time);
                
            end
            
        end
        
    end
        
    methods(Static=true)
       
        function val = range
           
            val = 0.1;
            
        end
        
        function dp = makeRandomParticles(number)
            
            if nargin<1 || isempty(number)
               number = 10;
            end
            
            for ii = 1:number
               
                dp(ii) = particle.TestParticle('rand','rand');
                
            end
            
        end
                
    end
    
end