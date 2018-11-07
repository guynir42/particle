classdef Point < handle % inherits from handle class (i.e., a pointer)
% Point class keeps track of x,y,z coordinates and can set/get them using
% spehrical coordinates, too. 
% Can generate a random point in the range [-10,10] using obj=Point('rand')
% Can plot the points on the current axes using point_vec.plot2D
%
% This class is the base class for TestParticle and Planet. 
    
    properties
       
        % coordinates in space (default is 0,0,0)
        x = 0;
        y = 0; 
        z = 0;
        
    end
    
    properties(Dependent=true) % these will only be accessible through getters/setter (they never really hold a value)
       
        R; % same units as x,y,z
        Th; % radians
        Ph; % radians
        
    end
    
    methods % this block is for the constructor (matlab allows only one)
       
        function obj = Point(varargin)
            
            if isempty(varargin) % this is the default constructor!
                return;
            end
            
            if isa(varargin{1}, 'particle.Point') % in this case, this is the copy constructor
                
                obj.x = varargin{1}.x;
                obj.y = varargin{1}.y;
                obj.z = varargin{1}.z;
                % do this manually, or use obj = util.oop.full_copy(varargin{1})
                
            else % just use any input parameters to make this object
                
                if isnumeric(varargin{1}) && length(varargin{1})>1 % only the first term is a vector 
                    
                    vec = varargin{1}; % assume the first input is a vector
                    obj.x = vec(1);
                    if length(vec)>=2, obj.y = vec(2); end
                    if length(vec)>=3, obj.z = vec(3); end
                    
                elseif isnumeric(varargin{1}) && length(varargin)>1 % there are multiple parameters to varargin
                    
                    obj.x = varargin{1};
                    obj.y = varargin{2};
                    if length(varargin)>=3, obj.z = varargin{3}; end
                      
                elseif ischar(varargin{1}) % additional options for initialization
                    
                    if strcmpi(varargin{1}, 'rand') % allow random point placement between -10 and 10
                        obj.x = (rand(1)-0.5)*2*particle.Point.range;
                        obj.y = (rand(1)-0.5)*2*particle.Point.range;
                        obj.z = (rand(1)-0.5)*2*particle.Point.range;
                    end
                    
                end
                    
            end
                        
        end
        
    end
    
    methods % block for getters
       
        function val = get.R(obj) % note the first argument to any non-static function must be obj (or self, or whatever name you want)
            
            val = sqrt(obj.x.^2+obj.y.^2+obj.z.^2); % calculate R from other properties of the object
            
        end
        
        function val = get.Th(obj)
            
            val = atan2(sqrt(obj.x^2 + obj.y.^2), obj.z); % calculate Th from other properties of the object
            
        end
       
        function val = get.Ph(obj)
            
            val = atan2(obj.y, obj.x); % calculate Ph from other properties of the object
            
        end
        
        % these are not formal getters, but I still like to group them with the get.* functions
        function vec = getXYZ(obj) % returns the coordinates as a row vector
            
            vec = [obj.x obj.y obj.z];
            
        end
        
        function d = dist(obj, other_point)
           
            if ~isa(other_point, 'particle.Point')
                error('please enter a Point object');
            end
            
            d = sqrt(sum((obj.getXYZ-other_point.getXYZ).^2));
            
        end
        
        function vec = getDirectionVector(obj, other_point) % get r_hat
            
            if ~isa(other_point, 'particle.Point')
                error('please enter a Point object');
            end
            
            vec = other_point.getXYZ - obj.getXYZ;
            vec = vec./sqrt(vec.^2); % normalize
            
        end
        
        function val = thetaTo(obj, other_point)
           
            if ~isa(other_point, 'particle.Point')
                error('please enter a Point object');
            end
           
            val = atan2(sqrt((obj.x-other_point.x).^2+(obj.y-other_point.y).^2), obj.z-other_point.z);
            
        end
        
        function val = phiTo(obj, other_point)
           
            if ~isa(other_point, 'particle.Point')
                error('please enter a Point object');
            end
           
            val = atan2(obj.y-other_point.y, obj.x-other_point.x);
            
        end
        
    end
    
    methods % block for setters
        
        function set.R(obj, val)
        
            r = val; % notice we change the value of R
            th = obj.Th;
            ph = obj.Ph;
            
            obj.setRThPh(r,th,ph); 
            
        end
        
        function set.Th(obj, val)
            
            r = obj.R;
            th = val; % notice we change the value of R
            ph = obj.Ph;
            
            obj.setRThPh(r,th,ph); 
            
        end
        
        function set.Ph(obj, val)
            
            r = obj.R;
            th = obj.Th;
            ph = val;
            
            obj.setRThPh(r,th,ph); 
            
        end
        
        % these are not formal setters, but I still like to group them with the set.* functions
        function setRThPh(obj, varargin)
         
            vec = Point.inputToVector(varargin{:}); % utility that converts varargin input to a row vector
            % notice the call to static function doesn't need an object (but uses the namespace)
            
            r = vec(1);
            th = vec(2);
            ph = vec(3);
            
            obj.x = r.*cos(ph).*sin(th);
            obj.y = r.*sin(ph).*sin(th);            
            obj.z = r.*cos(th);
            
        end
            
        function setXYZ(obj, varargin)
            
            vec = Point.inputToVector(varargin{:}); % utility that converts varargin input to a row vector
            
            obj.x = vec(1);
            obj.y = vec(2);
            obj.z = vec(3);
            
        end
        
            
    end
    
    methods % actions or mutators
       
        function move(obj, varargin) % use this to tell the object what to do/change
           
            vec = particle.Point.inputToVector(varargin{:}); % utility that converts varargin input to a row vector
            
            obj.x = obj.x + vec(1);
            obj.y = obj.y + vec(2);
            obj.z = obj.z + vec(3);
            
        end
        
    end
    
    methods % plotting tools
       
        function plot2D(obj, format_string) % take a vector of Point objects and show them on current axes. 
           
            if nargin<2 || isempty(format_string)
                format_string = 'o'; % default value
            end
            
            % get the coordinates 
            all_x = [obj.x]; % convert a comma separated list to a vector
            all_y = [obj.y]; % note that "obj" can implicitely be called as a vector of Point objects
            
            plot(all_x, all_y, format_string);
            
            axis([-particle.Point.range particle.Point.range -particle.Point.range particle.Point.range]);
            
        end
        
    end
    
    methods(Static=true) % utilities, constants, functions that can be called on a group of Points or whatever (they don't need a specific object to be called upon
               
        function vec = inputToVector(varargin) % checks the input for a three parameter vector and puts into a row vector
        
            vec = zeros(1,3);
            
            if length(varargin)==1 && isnumeric(varargin{1}) && length(varargin{1})==3 && isvector(varargin{1})
                
                vec = varargin{1};                
                if iscolumn(vec)
                    vec = vec';
                end
                
            elseif length(varargin)==3 && isnumeric(varargin{1}) && isscalar(varargin{1}) && isnumeric(varargin{2}) && isscalar(varargin{2}) && isnumeric(varargin{3}) && isscalar(varargin{3})
                
                vec(1) = varargin{1};
                vec(2) = varargin{2};
                vec(3) = varargin{3};
                
            else
                error('input must be a 3 member vector or 3 member cell-array');                
            end
            
        end
        
        function val = range % use this as a static const value that can be changed by rewriting this part. 
            % To let it be changed by the user is a bit trickier with persistent variables. 
            
            val = 5;
            
        end
        
    end
    
end