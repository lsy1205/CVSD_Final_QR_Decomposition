% Nr = 4;
% Nt = 4;
% H = (sqrt(1/2)*(randn(Nr, Nt)+1j*randn(Nr,Nt)))/sqrt(Nt);

Nr = 4;
Nt = 4;
H = (sqrt(1/2)*(randn(Nr, Nt)+1j*randn(Nr,Nt)))/sqrt(Nt);
disp(H);

a = real(H(1,1))^2;
b = imag(H(1,1))^2;
c = real(H(2,1))^2;
d = imag(H(2,1))^2;
e = real(H(3,1))^2;
f = imag(H(3,1))^2;
g = real(H(4,1))^2;
h = imag(H(4,1))^2;

k = a+b+c+d+e+f+g+h;
disp(k);
l = abs(H(1,1))^2 + abs(H(2,1))^2 + abs(H(3,1))^2 + abs(H(4,1))^2;
disp(l);
H_norm = zeros(1,4);
for j = 1:4
    for k = 1:4
        H_norm(k) = H_norm(k) + abs(H(j,k))^2;
    end
end
disp(H_norm);
