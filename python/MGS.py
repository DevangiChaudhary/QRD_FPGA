#MODIFIED GRAM SCHMIDT
import sys

#4x4 gram schmidt for testing
def mgs(n,A): #A is nxn matrix, list of n lists of n elements
    #check if input is proper
    try:
        #matrix type check
        if not isinstance(A, list):
            raise TypeError("Input should be list of lists")
        
        #rows check, should be 4
        if len(A)!=n:
            raise ValueError(f"number of rows should be {n}, not {len(A)}")
        
        #column check, should be 4
        for i, rows in enumerate(A):
            if len(rows)!=n:
                raise ValueError(f"number of columns should be {n}. in row {i} there are {len(rows)} elements")
    
    except (ValueError, TypeError):
        print("Wrong input. bye :(")
        sys.exit(1)
    
    V=[[0 for _ in range(n)] for _ in range(n)]
    for j in range(n):
        editcol(col(A,j),V,j)
    
    Q=[[0 for _ in range(n)] for _ in range(n)]
    R=[[0 for _ in range(n)] for _ in range(n)]
    for j in range(n):
        v_j=col(V,j)
        R[j][j]=norm(v_j)
        l=1/R[j][j]
        q_j=scalarmul(v_j,l)
        for k in range(j+1,n):
            v_k=col(V,k)
            R[j][k]=dotpro(q_j,v_k)
            coeff=(-1)*R[j][k]
            v_k=vecadd(v_k,scalarmul(q_j,coeff))
            editcol(v_k,V,k)
        editcol(q_j,Q,j)
    
    return Q, R

#vector addition
def vecadd(v,w):
    rows=len(v)
    col=len(v[0])
    ADD=[[0 for _ in range(col)] for _ in range(rows)]
    for i in range(rows):
        for j in range(col):
            ADD[i][j]=v[i][j]+w[i][j]
    return ADD

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

#edit column
def editcol(v,V,col_num):
    rows=len(V)
    for i in range(rows):
        V[i][col_num]=v[i][0]

#column extraction
def col(A, col_num):
    rows=len(A)
    v=[[0]for _ in range(rows)]
    for i in range(rows):
        v[i]=[A[i][col_num]]
    return v

#L2 norm
def norm(v):
    rows=len(v)
    s=0
    for i in range(rows):
        s+=(v[i][0]**2)
    return s**0.5

#scalar multiplication with matrix
def scalarmul(A,s):
    rows=len(A)
    col=len(A[0])
    M=[[0 for _ in range(col)] for _ in range(rows)]
    for i in range(rows):
        for j in range(col):
            M[i][j]=s*A[i][j]
    return M

####################################################
def main():
    n=int(input("Size of the square matrix: "))
    A=[[0 for _ in range(n)] for _ in range(n)]
    for i in range(n):
        for j in range(n):
            A[i][j]=float(input(f"Element {i},{j} =")) 
    print(A)

    Q,R=mgs(n,A)
    
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
    

if __name__=="__main__":
    main()
