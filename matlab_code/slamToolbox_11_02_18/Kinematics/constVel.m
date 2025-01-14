function [Xo, Xo_x, Xo_u] = constVel(X, u, dt)

% CONSTVEL  Constant velocity motion model.
%   X = CONSTVEL(X, U, DT) performs one time step to the constant velocity
%   model:
%       x = x + v*dt
%       q = q . v2q(w*dt)
%       v = v + uv
%       w = w + uw
%
%   where 
%       X = [x;q;v;w] is the state consisting of position, orientation
%           quaternion, linear velocity and angular velocity,
%       U = [uv;uw] are linear and angular velocity perturbations or
%           controls,
%       DT is the sampling time.
%
%   X = CONSTVEL(X, DT) assumes U = zeros(6,1).
%
%   [X, X_x, X_u] = CONSTVEL(...) returns the Jacobians wrt X and U.
%
%   See also RPREDICT, QPREDICT, V2Q, QUATERNION.

%   Copyright 2008-2009 Joan Sola @ LAAS-CNRS.


if nargin == 2
    dt = u;
    u = zeros(6,1);
end

% split inputs
x = X(1:3);   % position
q = X(4:7);   % orientation
v = X(8:10);  % linear velocity
w = X(11:13); % angular velocity

uv = u(1:3);  % linear vel. change (control)
uw = u(4:6);  % angular vel. change (control)

if nargout == 1

    % time step
    v = v + uv;
    w = w + uw;
    x = rpredict(x,v,dt);
    q = qpredict(q,w,dt,'exact');
  
    
    % new pose
    Xo = [x;q;v;w];

else % Jacobians

    % time step and Jacobians
    v = v + uv;
    w = w + uw;
    [x,Xx,Xv] = rpredict(x,v,dt);
    [q,Qq,Qw] = qpredict(q,w,dt);

    [Vv,Ww,Vuv,Wuw]   = deal(eye(3));
        
    % some constants
    Z34 = zeros(3,4);
    Z43 = zeros(4,3);
    Z33 = zeros(3);

    % new pose
    Xo = [x;q;v;w];

    % Full Jacobians
    Xo_x  = [...
        Xx  Z34 Xv  Z33
        Z43 Qq  Z43 Qw
        Z33 Z34 Vv  Z33
        Z33 Z34 Z33 Ww ]; % wrt state

    Xo_u  = [...
        Vuv*dt Z33
        Z43   Qw*dt 
        Vuv Z33
        Z33 Wuw];  % wrt control

end


% ========== End of function - Start GPL license ==========


%   # START GPL LICENSE

%---------------------------------------------------------------------
%
%   This file is part of SLAMTB, a SLAM toolbox for Matlab.
%
%   SLAMTB is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   SLAMTB is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with SLAMTB.  If not, see <http://www.gnu.org/licenses/>.
%
%---------------------------------------------------------------------

%   SLAMTB is Copyright 2007,2008,2009 
%   by Joan Sola, David Marquez and Jean Marie Codol @ LAAS-CNRS.
%   See on top of this file for its particular copyright.

%   # END GPL LICENSE

