def main():
    A=[
        [1.0,2.0,1.0],
        [3.0,8.0,1.0],
        [0.0,4.0,1.0]
    ]

    print(inverse(A))

    #check if matrix is Zero Matrix
    if(zero_mat(A)==0):
        #LU decomposition
        # EPA=U -> PA=LU -> L=E-1
        print(f"------------------LU-----------------")
        Pmat=Imatrix(A)
        Emat=Imatrix(A)
        U=A
        #Go column wise. 
        for col in range(len(A)):
            x=col
            if U[col][col]==0.0:
                #find non zero value in that column
                for i in range(col+1,len(A)):
                    if U[i][col]!=0.0:
                        #exchange rows to get non-zero value at col,col
                        x=i
                        break
            P=Pmatrix(A, x, col)
            E=Ematrix(U, col)
            print("for col:",col, "P", P, "E",E)
            U=multiplication(P,U)
            U=multiplication(E,U)
            Pmat=multiplication(P,Pmat)
            Emat=multiplication(E,Emat)
            print("Emat",Emat)
            print("temp", U)
        
        print("permutations", Pmat)
        print("elementary", Emat)
        print("U", U)
        L=inverse(Emat)
        print("L", L)
        print()
        print(A)
        print("validate", multiplication(Pmat,A), "=", multiplication(L,U))

        #LDU' decomposition
        #PA=LDU'. L and U both have 1 in diagonal. EU=U' -> U=DU' -> D=E-1
        print("------------------LDU------------------")
        D_I=Imatrix(U)
        for i in range(len(U)):
            D_I[i][i]=(1.0)/(U[i][i])
        
        Un=multiplication(D_I,U)
        D=inverse(D_I)
        print("U'", Un)
        print("D", D)
        print()
        print("validate", multiplication(Pmat,A), "=", multiplication(L,multiplication(D,Un)))       


#matrix multiplication nxm and mxp
def multiplication(v,w): #v*w
    n=len(v)
    m=len(w)
    p=len(w[0])
    t=[[0 for _ in range(p)] for _ in range(n)]
    for i in range(n):
        for j in range(p):
            for k in range(m):
                t[i][j]+=(v[i][k]*w[k][j])
    
    return t

#Identity Matrix
def Imatrix(A):
    I=[[0.0 for _ in range(len(A))] for _ in range(len(A))]

    for i in range(len(A)):
        for j in range(len(A)):
            if i==j:
                I[i][j]=1.0
    
    return I

#Permutation Matrix
def Pmatrix(A,r1,r2):
    P=Imatrix(A)

    temp=P[r1]
    P[r1]=P[r2]
    P[r2]=temp

    return P

#Elementary Matrices
def Ematrix(A, col):
    E=Imatrix(A)

    for i in range(col+1, len(A)):
        E[i][col]=(-1.0)*((A[i][col])/A[col][col])

    return E

#Inverse Matrix (Gauss-Jordan)
def inverse(A):
    # go column wise
    Et=Imatrix(A)
    M=A
    for col in range(len(A)):
        x=col
        if M[col][col]==0.0:
            for i in range(col+1, len(A)):
                if M[i][col]!=0.0:
                    x=i
                    break
        P=Pmatrix(M,x,col)
        M=multiplication(P,M)
        Et=multiplication(P,Et)

        E=Imatrix(A)
        #elimination for all rows except row=col
        for j in range(len(A)):
            if j!=col:
                E[j][col]=(-1.0)*((M[j][col])/M[col][col])
            else:
                E[col][col]=(1.0)/(M[col][col])
        
        M=multiplication(E,M)
        Et=multiplication(E, Et)
    #print(M)
    #print(Et)
    return Et

def zero_mat(v):
    t=0
    for i in v:
        for j in i:
            if j!=0.0:
                t=1
    
    if t==0:
        return 1
    else:
        return 0

if __name__=="__main__":
    main()
