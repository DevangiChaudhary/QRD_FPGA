#CLASSICAL GRAM SCHMIDT

def main():
    n=int(input("Size of the square matrix: "))
    A=[[0 for _ in range(n)] for _ in range(n)]
    for i in range(n):
        for j in range(n):
            A[i][j]=float(input(f"Element {i},{j} =")) 
    print(A)

    #Orthogonal Matrix
    Q=[[0 for _ in range(n)] for _ in range(n)]
    for j in range(n):
        a_j=col(A,j)
        v_j=a_j
        for k in range(j):
            q_k=col(Q,k)
            coeff=(-1)*dotpro(q_k,a_j)
            term=scalarmul(q_k,coeff)
            v_j=vecadd(v_j,term)
        l=1/norm(v_j)
        q_j=scalarmul(v_j,l)
        editcol(q_j,Q,j)
    
    #upper triangle matrix
    R=[[0 for _ in range(n)] for _ in range(n)]
    for i in range(n):
        q_i=col(Q,i)
        for j in range(n):
            a_k=col(A,j)
            if i>j:
                R[i][j]=0
            else:
                R[i][j]=dotpro(q_i,a_k)

    print("Q^T Q = ", multiplication(trans(Q),Q))
    
    print(f"""
        --------------------------------
                GRAM SCHMIDT RESULT
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

#column extraction
def col(A, col_num):
    rows=len(A)
    v=[[0]for _ in range(rows)]
    for i in range(rows):
        v[i]=[A[i][col_num]]
    return v

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

#L2 norm
def norm(v):
    rows=len(v)
    s=0
    for i in range(rows):
        s+=(v[i][0]**2)
    return s**0.5

#edit column
def editcol(v,V,col_num):
    rows=len(V)
    for i in range(rows):
        V[i][col_num]=v[i][0]

if __name__=="__main__":
    main()
