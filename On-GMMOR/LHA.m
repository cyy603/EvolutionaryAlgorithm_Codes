function Fs=LHA(PF,lambda)
% PF is a set of nondomiated solutions 
% Fs is the selected objectives 

%% normalization for PF
[N,M]=size(PF);
for i=1:M
     if max(PF(:,i))~=min(PF(:,i))
        NPF(:,i)=(PF(:,i)-min(PF(:,i)))/(max(PF(:,i))-min(PF(:,i)));
     else
        NPF(:,i)=ones(N,1);
     end   
end
% max_PF=max(PF);
% min_PF=min(PF);
% NPF=(PF-repmat(min_PF,N,1))./repmat(max_PF-min_PF,N,1);

%Q=[0.1:0.1:0.9,1:10];
Q=[1];
error=inf*ones(1,length(Q));
W=zeros(M,length(Q));
for i=1:length(Q)
    NPFq=NPF.^Q(i); 
    
%     b=ones(N,1);
%     cvx_begin quiet
%          variable c(M) nonnegative 
%           minimize ( (NPF*c-b)'*(NPF*c-b)+lambda*norm(c,1) )
% %           minimize ( sum((NPF*c-b).^2)+lambda*norm(c,1) )
% %            minimize ( norm(NPF*c-b,2)+lambda*norm(c,1) )
%     cvx_end       
%     error(i)=sum((NPF*c-b).^2)+norm(c,1);
%     W(:,i)=c;
%%    
    H=2*(NPFq'*NPFq);
    f=(lambda.*ones(M,1)'-2*ones(N,1)'*NPFq)';
    A=-eye(M);
    b=zeros(M,1);  
    Aeq=[];
    beq=[];
    LB=zeros(M,1);
    UB=+inf*ones(M,1);
    options = optimoptions(@quadprog,'Algorithm','interior-point-convex','MaxIter',1000,'display','off');
    w0=rand(M,1);
    W(:,i)=quadprog(H,f,A,b,Aeq,beq,LB,UB,w0,options)';
%     W(:,i)=quadprog(H,f,A,b,Aeq,beq,LB,UB);
    error(i)=W(:,i)'*(NPF'*NPF)*W(:,i)-(ones(M,1)'+2*ones(N,1)'*NPF)*W(:,i)+N;    
end
[~,best_q_index]=min(error);
%best_q=Q(best_q_index);
w=W(:,best_q_index);
Fs=find(w>0.1*max(w));
if length(Fs)==1
   R=corrcoef(PF);
   [~,minid]=min(R(Fs,:));
   Fs=[Fs;minid];
   Fs=sort(Fs);
end
end