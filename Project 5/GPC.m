clear
clc
[n1,d1,n2,d2]=Inputsys(3);
Gs1 = tf(n1,d1);
Ts=0.1;
Gd1 = c2d(Gs1,Ts,'zoh');
[num1,den1]=tfdata(Gd1,'v');
Gs2 = tf(n2,d2);
Gd2 = c2d(Gs2,Ts,'zoh');
[num2,den2]=tfdata(Gd2,'v');
sys_info = stepinfo(Gd1);
ts1 = sys_info.SettlingTime;
tr1=sys_info.RiseTime; 
sys_info = stepinfo(Gd2);
ts2 = sys_info.SettlingTime;
tr2=sys_info.RiseTime;
t=1:Ts:30;
[g1,t1] = step(Gd1,t);
[g2,t2] = step(Gd2,t);
P1=floor(tr1/Ts);
P2=floor(tr2/Ts);
N1=floor( ts1/Ts);
N2=floor( ts2/Ts);
P=max(P1,P2);
N=max(N1,N2);
M=P;
%.....................Toeplitz Matrix.................................
b1 = zeros(1,P); b1(1,1)= g1(2);
a1 = g1(2:P+1);
G1 = toeplitz(a1,b1);
G1(:,M) = G1(:,M:P)*ones(P-M+1,1);
G1 = G1(:,1:M);
%........................................................
b2 = zeros(1,P); b2(1,1)= g2(2);
a2 = g2(2:P+1);
G2 = toeplitz(a2,b2);
G2(:,M) = G2(:,M:P)*ones(P-M+1,1);
G2 = G2(:,1:M);
G=[G1 G2];
%........................................................................................
%A~=1-2.564z^-1+2.2365z^-2-0.6725z^-3
%A2~=1-2.411z^-1+1.9514z^-2-0.5404z^-3
%A3~=1-2.725z^-1+2.5357z^-2-0.8107z^-3
% According to the discrete transfer function, below parameters have been
% defined
na=3;
nb1=1; nb2=1;
nb=nb1;
d=0;
N1=d+1;
N2=d+P;
%...................................................
%a_=[1 -2.564 2.2365 -0.6725];
%a_=[1 -2.411 1.9514 -0.5404];
a_=[1 -2.725 2.5357 -0.8107];
%...................................................
b1_=num1(2:end);
b2_=num2(2:end);
C=1;  % because of using white noise
f=zeros(P+d,na+1);
f(1,1:3)=-1*a_(2:4);
for j=1:P+d-1
    for i=1:na
        f(j+1,i)=f(j,i+1)-f(j,1)*a_(i+1);
    end
end
F=f(N1:N2,1:na);
%.......................................
E1=zeros(P);
E1(:,1)=1;
for j=1:P-1
    E1(j+1:P,j+1)=f(j,1);
end
B1=zeros(P,P+nb);
for k=1:P
        B1(k,k:k+1)=b1_;
end
m1_=E1*B1;
M1_=zeros(P,nb+d);
for k=1:P
    M1_(k,:)=m1_(k,k+1);
end
%............................
E2=zeros(P);
E2(:,1)=1;
for j=1:P-1
    E2(j+1:P,j+1)=f(j,1);
end
B2=zeros(P,P+nb);
for k=1:P
        B2(k,k:k+1)=b2_;
end
m2_=E2*B2;
M2_=zeros(P,nb+d);
for k=1:P
    M2_(k,:)=m2_(k,k+1);
end
M_=[M1_ M2_];
%...............................................................................
gamma =1;
gain_DC=(num1(1)+num1(2)+num1(3))/(den1(1)+den1(2)+den1(3));
gain_DC2=(num2(1)+num2(2)+num2(3))/(den2(1)+den2(2)+den2(3));
Q = eye(P);
R1 =((1.2)^2)*gamma*gain_DC^2*eye(M);
R2=gamma*gain_DC2^2*eye(M);
R=[R1 zeros(M); zeros(M) R2];
alpha=0.5;
Kgpc=(G'*Q*G+R)\(G'*Q);
%.......................................................
% x01=0.0882;
% x02=441.2;
% x01=0.0748;
% x02=445.3;
x01=0.1055;
x02=436.8;
%.........................................................
%...................................................................................
dU1_=zeros(nb+d,length(t));
dU2_=zeros(nb+d,length(t));
dU_=[dU1_;dU2_];
d1=zeros(1,length(t));
%..................................
%y1=0; %linear
%y1=441.2;
%y1=445.3;
%...................................
y1=436.8;
u_1=[];
u_2=[];
ym=[];
y=0;
Y_d=zeros(P,length(t));
Y_past=zeros(P,length(t));
Y_m=zeros(P,length(t));
D=zeros(P,length(t));
E=zeros(P,length(t));
dU1=zeros(M,length(t));
dU2=zeros(M,length(t));
dU=[dU1;dU2];
U1=zeros(M,length(t));
U2=zeros(M,length(t));
Y_=zeros(na,length(t));
dU0=dU;
dU0(1,1)=0.001;
dU0(P+1,1)=0.001;
%..................step...........................
r =ones(length(t),1);
%...........................................................................................................

for i=1:length(t)-1 
    
for j=1:P
  Y_d(j,i+1)=(alpha^j)*y+(1-(alpha)^j)*r(i+1); % Programmed
end 

Y_past(:,i+1)=M_*dU_(:,i+1)+F*Y_(:,i+1);
D(:,i+1)=d1(i+1)*ones(P,1);

E(:,i+1)=Y_d(:,i+1)-Y_past(:,i+1)-D(:,i+1);

%dU(:,i+1)=Kgpc*E(:,i+1);
H = 2*(G'*Q*G+R);
 f = -(2*E(:,i+1)'*Q*G)';
ub1=0.65*ones(P,1)-U1(1,i);
ub2=-0.1*ones(P,1)-U2(1,i);
ub=[ub1; ub2];
lb1=0.3*ones(P,1)-U1(1,i);
lb2=-0.6*ones(P,1)-U2(1,i);
lb=[lb1; lb2];
opts = optimoptions('quadprog','Algorithm','interior-point-convex','Display','off');
dU(:,i+1)= quadprog(H,f,[],[],[],[],lb,ub,dU0(:,i),opts);
dU0(:,i+1)=dU(:,i+1);
dU1(:,i+1)=dU(1:M,i+1);
dU2(:,i+1)=dU(M+1:2*M,i+1);
U1(1,i+1)=dU1(1,i+1)+U1(1,i);
U2(1,i+1)=dU2(1,i+1)+U2(1,i);
dU(:,i+1)=[dU1(:,i+1);dU2(:,i+1)];

Y_m(:,i+1)=G*dU(:,i+1)+Y_past(:,i+1);

dU1_(2:nb+d,i+2) = dU1_(1:nb+d-1,i+1);
dU1_(1,i+2)=dU1(1,i+1);
dU2_(2:nb+d,i+2) = dU2_(1:nb+d-1,i+1);
dU2_(1,i+2)=dU2(1,i+1);
dU_(:,i+2)=[dU1_(:,i+2);dU2_(:,i+2)];
Y_(2:na,i+2)=Y_(1:na-1,i+1);
Y_(1,i+2)=Y_m(1,i+1);

%.......................................
% u1=U1(1,i+1)+100;
% u2=U2(1,i+1)+100;
% u1=U1(1,i+1)+103;
% u2=U2(1,i+1)+97;
u1=U1(1,i+1)+97;
u2=U2(1,i+1)+103;
u13=U1(1,i+1);
u23=U2(1,i+1);
%.......................................
sim('Model')
%............................................................
%d1(i+2)=y(end)-Y_m(1,i+1)-441.2;
%d1(i+2)=y(end)-Y_m(1,i+1)-445.3;
d1(i+2)=y(end)-Y_m(1,i+1)-436.8;
%...........................................................
%..........................................................................
% y=y(end)-441.2;%+dist(i,1);    % nonlinear
% y=y(end)-445.3;%+dist(i,1);    % nonlinear
y=y(end)-436.8;%+dist(i,1);    % nonlinear
%.........................................................................
%.....................................................................
% y1=[y1; y+441.2];
% y1=[y1; y+445.3];
y1=[y1; y+436.8];
%...................................................................
ym=[ym; Y_m(1,i)];
u_1=[u_1; u13];
u_2=[u_2; u23];
x01=x1(end);
x02=x2(end);

end

figure(3);
subplot(2,2,1);
plot(y1,'b');
hold on
%..........................
% plot(r+441.2,'r');
% plot(r+445.3,'r');
plot(r+436.8,'r');
%..........................
 grid on
legend('y','r');
title('Response of the nonlinear system');
xlabel('sample');
subplot(2,2,2);
%...............................
% plot(y1-441.2,'b');
% plot(y1-445.3,'b');
plot(y1-436.8,'b');
%................................
hold on
plot(ym,'r');
grid on
xlabel('sample');
title('Ym and Yp without bias');
legend('YPlant','YModel');
subplot(2,2,3);
plot(u_1,'b');
grid on
xlabel('sample');
title('Control law for input 1 without bias');
subplot(2,2,4);
plot(u_2,'b');
grid on
xlabel('sample');
title('Control law for input 2 without bias');
