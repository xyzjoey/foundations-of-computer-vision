function [K, R, t] = estimate_params(P)
% ESTIMATE_PARAMS computes the intrinsic K, rotation R and translation t from
% given camera matrix P.

[~, ~, V] = svd(P);
c = V(:,end);
c = c(1:3);

[R, K] = QR3(P(:, 1:3));
% [R, K] = qr(P(:, 1:3));


t = R*c;

end

function [Q,R] = QR3(A)

%     a1 = A(:,1);
%     a2 = A(:,2);
%     a3 = A(:,3);
%     
%     u1 = a1;
%     u2 = a2 - projUtoV(u1, a2);
%     u3 = a3 - projUtoV(u1, a3) - projUtoV(u2, a3);
%     
%     e1 = u1 / norm(u1);
%     e2 = u2 / norm(u2);
%     e3 = u3 / norm(u3);
%     
%     Q = [e1 e2 e3];
%     R = Q.' * A;
    
    eps = 1e-10;
    
    % Qx
    A(3,3) = A(3,3) + eps;
    c = -A(3,3)/sqrt(A(3,3)^2+A(3,2)^2);
    s =  A(3,2)/sqrt(A(3,3)^2+A(3,2)^2);
    Qx = [1 0 0; 0 c -s; 0 s c];
    R = A*Qx;
    
    % Qy
    R(3,3) = R(3,3) + eps;
    c = R(3,3)/sqrt(R(3,3)^2+R(3,1)^2);
    s = R(3,1)/sqrt(R(3,3)^2+R(3,1)^2);
    Qy = [c 0 s; 0 1 0;-s 0 c];
    R = R*Qy;
    
    % Qz    
    R(2,2) = R(2,2) + eps;
    c = -R(2,2)/sqrt(R(2,2)^2+R(2,1)^2);
    s =  R(2,1)/sqrt(R(2,2)^2+R(2,1)^2);    
    Qz = [c -s 0; s c 0; 0 0 1];
    R = R*Qz;
    
    Q = Qz'*Qy'*Qx';
    
    % R --> +ve
    for n = 1:3
        if R(n,n) < 0
            R(:,n) = -R(:,n);
            Q(n,:) = -Q(n,:);
        end
    end
end

function projV = projUtoV(u, v)
projV = (dot(u, v)/norm(v))*v;
end
