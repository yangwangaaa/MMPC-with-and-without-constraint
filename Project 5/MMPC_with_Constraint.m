clear
clc
%%....................................................................First Model...........................................................................
%%....................................................................................................................................................................
[n11,d11,n21,d21]=Inputsys(1);
Gs11 = tf(n11,d11);
Ts=0.1;
Gd11 = c2d(Gs11,Ts,'zoh');
[num11,den11]=tfdata(Gd11,'v');
Gs21 = tf(n21,d21);
Gd21 = c2d(Gs21,Ts,'zoh');
[num21,den21]=tfdata(Gd21,'v');
sys_info = stepinfo(Gd11);
ts11 = sys_info.SettlingTime;
tr11=sys_info.RiseTime; 
sys_info = stepinfo(Gd21);
ts21 = sys_info.SettlingTime;
tr21=sys_info.RiseTime;
t=1:Ts:30;
[g11,t11] = step(Gd11,t);
[g21,t21] = step(Gd21,t);
P11=floor(tr11/Ts);
P21=floor(tr21/Ts);
N11=floor( ts11/Ts);
N21=floor( ts21/Ts);
P1=max(P11,P21);
N=max(N11,N21);
M1=P1;
%.....................Toeplitz Matrix.................................
b11 = zeros(1,P1); b11(1,1)= g11(2);
a11 = g11(2:P1+1);
G11 = toeplitz(a11,b11);
G11(:,M1) = G11(:,M1:P1)*ones(P1-M1+1,1);
G11 = G11(:,1:M1);
%........................................................
b21 = zeros(1,P1); b21(1,1)= g21(2);
a21 = g21(2:P1+1);
G21 = toeplitz(a21,b21);
G21(:,M1) = G21(:,M1:P1)*ones(P1-M1+1,1);
G21 = G21(:,1:M1);
G1=[G11 G21];
%........................................................................................
%A1~=1-2.564z^-1+2.2365z^-2-0.6725z^-3
% According to the discrete transfer function, below parameters have been
% defined
na=3;
nb1=1; nb2=1;
nb=nb1;
d=0;
N11=d+1;
N21=d+P1;
%...................................................
a1_=[1 -2.564 2.2365 -0.6725];
%...................................................
b11_=num11(2:end);
b21_=num21(2:end);
C=1;  % because of using white noise
f1=zeros(P1+d,na+1);
f1(1,1:3)=-1*a1_(2:4);
for j=1:P1+d-1
    for i=1:na
        f1(j+1,i)=f1(j,i+1)-f1(j,1)*a1_(i+1);
    end
end
F1=f1(N11:N21,1:na);
%.......................................
E11=zeros(P1);
E11(:,1)=1;
for j=1:P1-1
    E11(j+1:P1,j+1)=f1(j,1);
end
B11=zeros(P1,P1+nb);
for k=1:P1
        B11(k,k:k+1)=b11_;
end
m11_=E11*B11;
M11_=zeros(P1,nb+d);
for k=1:P1
    M11_(k,:)=m11_(k,k+1);
end
%............................
E21=zeros(P1);
E21(:,1)=1;
for j=1:P1-1
    E21(j+1:P1,j+1)=f1(j,1);
end
B21=zeros(P1,P1+nb);
for k=1:P1
        B21(k,k:k+1)=b21_;
end
m21_=E21*B21;
M21_=zeros(P1,nb+d);
for k=1:P1
    M21_(k,:)=m21_(k,k+1);
end
M1_=[M11_ M21_];
%...............................................................................
gamma =1;
gain_DC11=(num11(1)+num11(2)+num11(3))/(den11(1)+den11(2)+den11(3));
gain_DC21=(num21(1)+num21(2)+num21(3))/(den21(1)+den21(2)+den21(3));
Q1 = eye(P1);
R11 =((1.2)^2)*gamma*gain_DC11^2*eye(M1);
R21=gamma*gain_DC21^2*eye(M1);
R1=[R11 zeros(M1); zeros(M1) R21];
alpha1=0.5;
Kgpc1=(G1'*Q1*G1+R1)\(G1'*Q1);
%%....................................................................................................................................................................................................
%%.............................................................................Second Model.............................................................................................
%%....................................................................................................................................................................................................
[n12,d12,n22,d22]=Inputsys(2);
Gs12 = tf(n12,d12);
Gd12 = c2d(Gs12,Ts,'zoh');
[num12,den12]=tfdata(Gd12,'v');
Gs22 = tf(n22,d22);
Gd22 = c2d(Gs22,Ts,'zoh');
[num22,den22]=tfdata(Gd22,'v');
sys_info = stepinfo(Gd12);
ts12 = sys_info.SettlingTime;
tr12=sys_info.RiseTime; 
sys_info = stepinfo(Gd22);
ts22 = sys_info.SettlingTime;
tr22=sys_info.RiseTime;
[g12,t1] = step(Gd12,t);
[g22,t2] = step(Gd22,t);
P12=floor(tr12/Ts);
P22=floor(tr22/Ts);
N12=floor( ts12/Ts);
N22=floor( ts22/Ts);
P2=max(P12,P22);
N2=max(N12,N22);
M2=P2;
%.....................Toeplitz Matrix.................................
b12 = zeros(1,P2); b12(1,1)= g12(2);
a12 = g12(2:P2+1);
G12 = toeplitz(a12,b12);
G12(:,M2) = G12(:,M2:P2)*ones(P2-M2+1,1);
G12 = G12(:,1:M2);
%........................................................
b22 = zeros(1,P2); b22(1,1)= g22(2);
a22 = g22(2:P2+1);
G22 = toeplitz(a22,b22);
G22(:,M2) = G22(:,M2:P2)*ones(P2-M2+1,1);
G22 = G22(:,1:M2);
G2=[G12 G22];
%........................................................................................
%A2~=1-2.411z^-1+1.9514z^-2-0.5404z^-3
% According to the discrete transfer function, below parameters have been
% defined
N12=d+1;
N22=d+P2;
%...................................................
a2_=[1 -2.411 1.9514 -0.5404];
%...................................................
b12_=num12(2:end);
b22_=num22(2:end);
C=1;  % because of using white noise
f2=zeros(P2+d,na+1);
f2(1,1:3)=-1*a2_(2:4);
for j=1:P2+d-1
    for i=1:na
        f2(j+1,i)=f2(j,i+1)-f2(j,1)*a2_(i+1);
    end
end
F2=f2(N12:N22,1:na);
%.......................................
E12=zeros(P2);
E12(:,1)=1;
for j=1:P2-1
    E12(j+1:P2,j+1)=f2(j,1);
end
B12=zeros(P2,P2+nb);
for k=1:P2
        B12(k,k:k+1)=b12_;
end
m12_=E12*B12;
M12_=zeros(P2,nb+d);
for k=1:P2
    M12_(k,:)=m12_(k,k+1);
end
%............................
E22=zeros(P2);
E22(:,1)=1;
for j=1:P2-1
    E22(j+1:P2,j+1)=f2(j,1);
end
B22=zeros(P2,P2+nb);
for k=1:P2
        B22(k,k:k+1)=b22_;
end
m22_=E22*B22;
M22_=zeros(P2,nb+d);
for k=1:P2
    M22_(k,:)=m22_(k,k+1);
end
M2_=[M12_ M22_];
%...............................................................................
gamma2 =1;
gain_DC12=(num12(1)+num12(2)+num12(3))/(den12(1)+den12(2)+den12(3));
gain_DC22=(num22(1)+num22(2)+num22(3))/(den22(1)+den22(2)+den22(3));
Q2 = eye(P2);
R12 =((1.2)^2)*gamma2*gain_DC12^2*eye(M2);
R22=gamma2*gain_DC22^2*eye(M2);
R2=[R12 zeros(M2); zeros(M2) R22];
alpha2=0.5;
Kgpc2=(G2'*Q2*G2+R2)\(G2'*Q2);
%%....................................................................................................................................................................................................
%%.............................................................................Third Model.............................................................................................
%%....................................................................................................................................................................................................
[n13,d13,n23,d23]=Inputsys(3);
Gs13 = tf(n13,d13);
Gd13 = c2d(Gs13,Ts,'zoh');
[num13,den13]=tfdata(Gd13,'v');
Gs23 = tf(n23,d23);
Gd23 = c2d(Gs23,Ts,'zoh');
[num23,den23]=tfdata(Gd23,'v');
sys_info = stepinfo(Gd13);
ts13 = sys_info.SettlingTime;
tr13=sys_info.RiseTime; 
sys_info = stepinfo(Gd23);
ts23 = sys_info.SettlingTime;
tr23=sys_info.RiseTime;
[g13,t13] = step(Gd13,t);
[g23,t23] = step(Gd23,t);
P13=floor(tr13/Ts);
P23=floor(tr23/Ts);
N13=floor( ts13/Ts);
N23=floor( ts23/Ts);
P3=max(P13,P23);
N3=max(N13,N23);
M3=P3;
%.....................Toeplitz Matrix.................................
b13 = zeros(1,P3); b13(1,1)= g13(2);
a13 = g13(2:P3+1);
G13 = toeplitz(a13,b13);
G13(:,M3) = G13(:,M3:P3)*ones(P3-M3+1,1);
G13 = G13(:,1:M3);
%........................................................
b23 = zeros(1,P3); b23(1,1)= g23(2);
a23 = g23(2:P3+1);
G23 = toeplitz(a23,b23);
G23(:,M3) = G23(:,M3:P3)*ones(P3-M3+1,1);
G23 = G23(:,1:M3);
G3=[G13 G23];
%........................................................................................
%A3~=1-2.725z^-1+2.5357z^-2-0.8107z^-3
% According to the discrete transfer function, below parameters have been
% defined
N13=d+1;
N23=d+P3;
%...................................................
a3_=[1 -2.725 2.5357 -0.8107];
%...................................................
b13_=num13(2:end);
b23_=num23(2:end);
C=1;  % because of using white noise
f3=zeros(P3+d,na+1);
f3(1,1:3)=-1*a3_(2:4);
for j=1:P3+d-1
    for i=1:na
        f3(j+1,i)=f3(j,i+1)-f3(j,1)*a3_(i+1);
    end
end
F3=f3(N13:N23,1:na);
%.......................................
E13=zeros(P3);
E13(:,1)=1;
for j=1:P3-1
    E13(j+1:P3,j+1)=f3(j,1);
end
B13=zeros(P3,P3+nb);
for k=1:P3
        B13(k,k:k+1)=b13_;
end
m13_=E13*B13;
M13_=zeros(P3,nb+d);
for k=1:P3
    M13_(k,:)=m13_(k,k+1);
end
%............................
E23=zeros(P3);
E23(:,1)=1;
for j=1:P3-1
    E23(j+1:P3,j+1)=f3(j,1);
end
B23=zeros(P3,P3+nb);
for k=1:P3
        B23(k,k:k+1)=b23_;
end
m23_=E23*B23;
M23_=zeros(P3,nb+d);
for k=1:P3
    M23_(k,:)=m23_(k,k+1);
end
M3_=[M13_ M23_];
%...............................................................................
gamma3 =1;
gain_DC13=(num13(1)+num13(2)+num13(3))/(den13(1)+den13(2)+den13(3));
gain_DC23=(num23(1)+num23(2)+num23(3))/(den23(1)+den23(2)+den23(3));
Q3 = eye(P3);
R13 =((1.2)^2)*gamma3*gain_DC13^2*eye(M3);
R23=gamma3*gain_DC23^2*eye(M3);
R3=[R13 zeros(M3); zeros(M3) R23];
alpha3=0.5;
Kgpc3=(G3'*Q3*G3+R3)\(G3'*Q3);
%..............................................................................................................................................................................
% x01=0.0882;
% x02=441.2;
% x01=0.0748;
% x02=445.3;
% x01=0.1055;
% x02=436.8;
x01=0.07;
x02=440;
%...................................................................................
ynl=[];
%.........................................................
%..................step...........................
r =445*ones(length(t),1);
%...................sine..............................
% [r1,t1]= gensig('sine',length(t)*Ts/2,length(t)*Ts,Ts);
% r=r1+445.3;
%...........................................................................................................
%%....................................................................................................................................................................................................
%%.............................................................................First Model.............................................................................................
%%....................................................................................................................................................................................................
dU11_=zeros(nb+d,length(t));
dU21_=zeros(nb+d,length(t));
dU1_=[dU11_;dU21_];
d1=zeros(1,length(t));
%..............................First...................................
u_1=[];
u_2=[];
ym1=[];
y1=0;
Y_d1=zeros(P1,length(t));
Y_past1=zeros(P1,length(t));
Y_m1=zeros(P1,length(t));
D1=zeros(P1,length(t));
E1=zeros(P1,length(t));
dU11=zeros(M1,length(t));
dU21=zeros(M1,length(t));
dU1=[dU11;dU21];
U11=zeros(M1,length(t));
U21=zeros(M1,length(t));
Y1_=zeros(na,length(t));
dU01=dU1;
dU01(1,1)=0.001;
dU01(P1+1,1)=0.001;
%...................second................................
dU12_=zeros(nb+d,length(t));
dU22_=zeros(nb+d,length(t));
dU2_=[dU12_;dU22_];
d2=zeros(1,length(t));
%...................................
ym2=[];
y2=0;
Y_d2=zeros(P2,length(t));
Y_past2=zeros(P2,length(t));
Y_m2=zeros(P2,length(t));
D2=zeros(P2,length(t));
E2=zeros(P2,length(t));
dU12=zeros(M2,length(t));
dU22=zeros(M2,length(t));
dU2=[dU12;dU22];
U12=zeros(M2,length(t));
U22=zeros(M2,length(t));
Y2_=zeros(na,length(t));
dU02=dU2;
dU02(1,1)=0.001;
dU02(P2+1,1)=0.001;
%..................Third....................................
dU13_=zeros(nb+d,length(t));
dU23_=zeros(nb+d,length(t));
dU3_=[dU13_;dU23_];
d3=zeros(1,length(t));
%..................................
ym3=[];
y3=0;
Y_d3=zeros(P3,length(t));
Y_past3=zeros(P3,length(t));
Y_m3=zeros(P3,length(t));
D3=zeros(P3,length(t));
E3=zeros(P3,length(t));
dU13=zeros(M3,length(t));
dU23=zeros(M3,length(t));
dU3=[dU13;dU23];
U13=zeros(M3,length(t));
U23=zeros(M3,length(t));
Y3_=zeros(na,length(t));
dU03=dU3;
dU3(1,1)=0.001;
dU3(P3+1,1)=0.001;
%........................................................................................................
%........................................................................................................
p=zeros(3,length(t));
p(1:3,2)=[0.3 0.4 0.3]';
p_=zeros(3,length(t));
p__=zeros(3,length(t));
e=zeros(2,length(t),3);
p1=p(1,2);
p2=p(2,2);
p3=p(3,2);

for i=1:length(t)-1 
    
for j=1:P1
  Y_d1(j,i+1)=(alpha1^j)*y1+(1-(alpha1)^j)*(r(i+1)-441.2); % Programmed
end 

Y_past1(:,i+1)=M1_*dU1_(:,i+1)+F1*Y1_(:,i+1);
D1(:,i+1)=d1(i+1)*ones(P1,1);

E1(:,i+1)=Y_d1(:,i+1)-Y_past1(:,i+1)-D1(:,i+1);

H1 = 2*(G1'*Q1*G1+R1);
 f1 = -(2*E1(:,i+1)'*Q1*G1)';
ub11=0.65*ones(P1,1)-U11(1,i);
ub21=-0.1*ones(P1,1)-U21(1,i);
ub1=[ub11; ub21];
lb11=0.3*ones(P1,1)-U11(1,i);
lb21=-0.6*ones(P1,1)-U21(1,i);
lb1=[lb11; lb21];
opts1 = optimoptions('quadprog','Algorithm','interior-point-convex','Display','off');
dU1(:,i+1)= quadprog(H1,f1,[],[],[],[],lb1,ub1,dU01(:,i),opts1);
dU01(:,i+1)=dU1(:,i+1);
dU11(:,i+1)=dU1(1:M1,i+1);
dU21(:,i+1)=dU1(M1+1:2*M1,i+1);
U11(1,i+1)=dU11(1,i+1)+U11(1,i);
U21(1,i+1)=dU21(1,i+1)+U21(1,i);
dU1(:,i+1)=[dU11(:,i+1);dU21(:,i+1)];

Y_m1(:,i+1)=G1*dU1(:,i+1)+Y_past1(:,i+1);

dU11_(2:nb+d,i+2) = dU11_(1:nb+d-1,i+1);
dU11_(1,i+2)=dU11(1,i+1);
dU21_(2:nb+d,i+2) = dU21_(1:nb+d-1,i+1);
dU21_(1,i+2)=dU21(1,i+1);
dU1_(:,i+2)=[dU11_(:,i+2);dU21_(:,i+2)];
Y1_(2:na,i+2)=Y1_(1:na-1,i+1);
Y1_(1,i+2)=Y_m1(1,i+1);

%.......................................
u11=U11(1,i+1)+100;
u21=U21(1,i+1)+100;
%%....................................................................................................................................................................................................
%%.............................................................................Second Model.............................................................................................
%%....................................................................................................................................................................................................
%...............................................................................................
    
for j=1:P2
  Y_d2(j,i+1)=(alpha2^j)*y2+(1-(alpha2)^j)*(r(i+1)-445.3); % Programmed
end 

Y_past2(:,i+1)=M2_*dU2_(:,i+1)+F2*Y2_(:,i+1);
D2(:,i+1)=d2(i+1)*ones(P2,1);

E2(:,i+1)=Y_d2(:,i+1)-Y_past2(:,i+1)-D2(:,i+1);

H2 = 2*(G2'*Q2*G2+R2);
 f2 = -(2*E2(:,i+1)'*Q2*G2)';
ub12=0.65*ones(P2,1)-U12(1,i);
ub22=-0.1*ones(P2,1)-U22(1,i);
ub2=[ub12; ub22];
lb12=0.3*ones(P2,1)-U12(1,i);
lb22=-0.6*ones(P2,1)-U22(1,i);
lb2=[lb12; lb22];
opts2 = optimoptions('quadprog','Algorithm','interior-point-convex','Display','off');
dU2(:,i+1)= quadprog(H2,f2,[],[],[],[],lb2,ub2,dU02(:,i),opts2);
dU02(:,i+1)=dU2(:,i+1);
dU12(:,i+1)=dU2(1:M2,i+1);
dU22(:,i+1)=dU2(M2+1:2*M2,i+1);
U12(1,i+1)=dU12(1,i+1)+U12(1,i);
U22(1,i+1)=dU22(1,i+1)+U22(1,i);
dU2(:,i+1)=[dU12(:,i+1);dU22(:,i+1)];

Y_m2(:,i+1)=G2*dU2(:,i+1)+Y_past2(:,i+1);

dU12_(2:nb+d,i+2) = dU12_(1:nb+d-1,i+1);
dU12_(1,i+2)=dU12(1,i+1);
dU22_(2:nb+d,i+2) = dU22_(1:nb+d-1,i+1);
dU22_(1,i+2)=dU22(1,i+1);
dU2_(:,i+2)=[dU12_(:,i+2);dU22_(:,i+2)];
Y2_(2:na,i+2)=Y2_(1:na-1,i+1);
Y2_(1,i+2)=Y_m2(1,i+1);

%.......................................
u12=U12(1,i+1)+103;
u22=U22(1,i+1)+97;
%.......................................
%%....................................................................................................................................................................................................
%%.............................................................................Third Model.............................................................................................
%%....................................................................................................................................................................................................

%...........................................................................................................
    
for j=1:P3
  Y_d3(j,i+1)=(alpha3^j)*y3+(1-(alpha3)^j)*(r(i+1)-436.8); % Programmed
end 

Y_past3(:,i+1)=M3_*dU3_(:,i+1)+F3*Y3_(:,i+1);
D3(:,i+1)=d3(i+1)*ones(P3,1);

E3(:,i+1)=Y_d3(:,i+1)-Y_past3(:,i+1)-D3(:,i+1);

H3 = 2*(G3'*Q3*G3+R3);
 f3 = -(2*E3(:,i+1)'*Q3*G3)';
ub13=0.65*ones(P3,1)-U13(1,i);
ub23=-0.1*ones(P3,1)-U23(1,i);
ub3=[ub13; ub23];
lb13=0.3*ones(P3,1)-U13(1,i);
lb23=-0.6*ones(P3,1)-U23(1,i);
lb3=[lb13; lb23];
opts3 = optimoptions('quadprog','Algorithm','interior-point-convex','Display','off');
dU3(:,i+1)= quadprog(H3,f3,[],[],[],[],lb3,ub3,dU03(:,i),opts3);
dU03(:,i+1)=dU3(:,i+1);
dU13(:,i+1)=dU3(1:M3,i+1);
dU23(:,i+1)=dU3(M3+1:2*M3,i+1);
U13(1,i+1)=dU13(1,i+1)+U13(1,i);
U23(1,i+1)=dU23(1,i+1)+U23(1,i);
dU3(:,i+1)=[dU13(:,i+1);dU23(:,i+1)];

Y_m3(:,i+1)=G3*dU3(:,i+1)+Y_past3(:,i+1);

dU13_(2:nb+d,i+2) = dU13_(1:nb+d-1,i+1);
dU13_(1,i+2)=dU13(1,i+1);
dU23_(2:nb+d,i+2) = dU23_(1:nb+d-1,i+1);
dU23_(1,i+2)=dU23(1,i+1);
dU3_(:,i+2)=[dU13_(:,i+2);dU23_(:,i+2)];
Y3_(2:na,i+2)=Y3_(1:na-1,i+1);
Y3_(1,i+2)=Y_m3(1,i+1);

%.......................................
u13=U13(1,i+1)+97;
u23=U23(1,i+1)+103;
%%.......................................................................................................................................................
u1=p(1,i+1)*u11+p(2,i+1)*u12+p(3,i+1)*u13;
u2=p(1,i+1)*u21+p(2,i+1)*u22+p(3,i+1)*u23;
U13(1,i+1)=u1-97;
U23(1,i+1)=u2-103;
U12(1,i+1)=u1-103;
U22(1,i+1)=u2-97;
U11(1,i+1)=u1-100;
U21(1,i+1)=u2-100;
%............................................................
sim('Model')
%............................................................
d1(i+2)=y(end)-Y_m1(1,i+1)-441.2;
d2(i+2)=y(end)-Y_m2(1,i+1)-445.3;
d3(i+2)=y(end)-Y_m3(1,i+1)-436.8;
%...........................................................
e(2:end,i+2,1)=e(1:end-1,i+1,1);
e(1,i+2,1)=d1(i+2);
e(2:end,i+2,2)=e(1:end-1,i+1,2);
e(1,i+2,2)=d2(i+2);
e(2:end,i+2,3)=e(1:end-1,i+1,3);
e(1,i+2,3)=d3(i+2);
%.............................................................................
sum=0;
for k=1:3
   sum=(1/e(1,i+2,k))+sum;
end
w=zeros(3,1);
for j=1:3
    w(j)=(1/e(1,i+2,j))/sum;
end
for j=1:3
    p(j,i+2)=w(j);
end
% [max1,ind1]=max(w);
% for j=1:3
%     if j==ind1
%         w(j)=-200;
%     end
% end
% [max2,ind2]=max(w);
% % res=[0.5 0; 0 0.1];
% % sum2=0;
% % for j=1:3
% %     sum2=exp(e(:,i+2,j)'*res*e(:,i+2,j))*p(j,i+1)+sum2;
% % end
% % p_(ind1,i+2)=(exp(e(:,i+2,ind1)'*res*e(:,i+2,ind1))*p(j,i+1))/sum2;
% % p_(ind2,i+2)=(exp(e(:,i+2,ind2)'*res*e(:,i+2,ind2))*p(j,i+1))/sum2;
% % delta=0.01;
% % if p_(ind1,i+2)>=delta
% %     p__(ind1,i+2)=p_(ind1,i+2);
% % else
% %     p__(ind1,i+2)=delta;
% % end
% % if p_(ind2,i+2)>=delta
% %     p__(ind2,i+2)=p_(ind2,i+2);
% % else
% %     p__(ind2,i+2)=delta;
% % end
% % sum3=0;
% % for j=1:3
% %     sum3=sum3+p__(j,i+2);
% % end
% % for j=1:3
% %     p(j,i+2)=p__(j,i+2)/sum3;
% % end
% p(ind1,i+2)=max1;
% p(ind2,i+2)=max2;
% for j=1:3
%     if j~=ind1 && j~=ind2
%         p(j,i+2)=0;
%     end
% end
% sum3=0;
% for j=1:3
%     sum3=sum3+p(j,i+2);
% end
% for j=1:3
%     p(j,i+2)=p(j,i+2)/sum3;
% end
%..........................................................................
y1=y(end)-441.2;%+dist(i,1);    % nonlinear
y2=y(end)-445.3;%+dist(i,1);    % nonlinear
y3=y(end)-436.8;%+dist(i,1);    % nonlinear
%.........................................................................
%.....................................................................
% y1=[y1; y+441.2];
% y1=[y1; y+445.3];
ynl=[ynl; y(end)];
%...................................................................
%ym=[ym; Y_m1(1,i)];
u_1=[u_1; u1];
u_2=[u_2; u2];
x01=x1(end);
x02=x2(end);
p1=[p1; p(1,i+2)];
p2=[p2; p(2,i+2)];
p3=[p3; p(3,i+2)];

end

figure(3);
subplot(2,2,1);
plot(ynl,'b');
hold on
%..........................
plot(r,'r');
% plot(r+445.3,'r');
%plot(r+436.8,'r');
%..........................
 grid on
legend('y','r');
title('Response of the nonlinear system');
xlabel('sample');
%subplot(2,2,2);
%...............................
% plot(y1-441.2,'b');
% plot(y1-445.3,'b');
%plot(ynl-436.8,'b');
%................................
% hold on
% plot(ym,'r');
% grid on
% xlabel('sample');
% title('Ym and Yp without bias');
% legend('YPlant','YModel');
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
figure
plot(p1,'b');
hold on
plot(p2,'m')
hold on
plot(p3,'c')
