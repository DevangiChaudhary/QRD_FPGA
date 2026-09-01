#Householder - Reflection transformations

def main():
    n=int(input("Size of the square matrix: "))
    A=[[0 for _ in range(n)] for _ in range(n)]
    for i in range(n):
        for j in range(n):
            A[i][j]=float(input(f"Element {i},{j} =")) 
    print(A)

    #working matrix
    R=[[0 for _ in range(n)] for _ in range(n)]
    for i in range(n):
        for j in range(n):
            R[i][j]=A[i][j]
    
    Q=Imatrix(n)
    #H matrix
    for j in range(n-1):
        v_j=col(R,j)
        if (v_j[0][0]>=0):
            coeff=+norm(v_j)
        else: coeff=-norm(v_j)
        Vj=vecadd(v_j,scalarmul(col(Imatrix(n),j),coeff))
        print(f"{Vj}")
        tau=(-2)/dotpro(Vj,Vj)
        h_j=vecadd(Imatrix(n-j),scalarmul(multiplication(Vj,trans(Vj)),tau))
        Hj=formh(h_j,n,j)
        print(f"Hj = {Hj} \n\n")
        R=multiplication(Hj,R)
        print(f"progress = {R} \n\n")
        Q=multiplication(Q,Hj)

    #fixing R to get zero below diagonal and not get really small value
    for i in range(n):
        for j in range(n):
            if i>j:
                R[i][j]=0.0
    
    print(f"""
        --------------------------------
                HOUSEHOLDER RESULTS
        --------------------------------

        Input Matrix A =
        {A}

        Orthonormal Matrix Q =
        {Q}

        Upper Triangle Matrix R =
        {R}

        Validating = 
        A = {A}
        QR = {multiplication(Q,R)}
        --------------------------------
        """)


#forming H
def formh(H,n,j):
    Hj=Imatrix(n)
    for i in range(n-j):
        for k in range(n-j):
            Hj[j+i][j+k]=H[i][k]
    return Hj

#dot product 
def dotpro(v,w):
    v_t=trans(v)
    return multiplication(v_t,w)[0][0]

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

#Transpose Matrix nxm
def trans(A):
    n=len(A)
    m=len(A[0])
    T=[[0 for _ in range(n)] for _ in range(m)]
    for i in range(n):
        for j in range(m):
            T[j][i]=A[i][j]
    return T

#scalar multiplication with matrix
def scalarmul(A,s):
    rows=len(A)
    col=len(A[0])
    M=[[0 for _ in range(col)] for _ in range(rows)]
    for i in range(rows):
        for j in range(col):
            M[i][j]=s*A[i][j]
    return M

#vector addition
def vecadd(v,w):
    rows=len(v)
    col=len(v[0])
    ADD=[[0 for _ in range(col)] for _ in range(rows)]
    for i in range(rows):
        for j in range(col):
            ADD[i][j]=v[i][j]+w[i][j]
    return ADD

#Identity Matrix
def Imatrix(n):
    I=[[0.0 for _ in range(n)] for _ in range(n)]
    for i in range(n):
        for j in range(n):
            if i==j:
                I[i][j]=1.0  
    return I

#L2 norm
def norm(v):
    rows=len(v)
    s=0
    for i in range(rows):
        s+=(v[i][0]**2)
    return s**0.5

#column extraction
def col(A, col_num):
    rows=len(A)-col_num
    v=[[0]for _ in range(rows)]
    for i in range(rows):
        v[i]=[A[i+col_num][col_num]]
    return v

if __name__=="__main__":
    main()