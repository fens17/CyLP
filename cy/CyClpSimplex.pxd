# cython: embedsignature=True


import pyximport
pyximport.install()

cimport cpython.ref as cpy_ref
from cpython.ref cimport PyObject
from CyLP.cy.CyClpPrimalColumnPivotBase cimport CyClpPrimalColumnPivotBase
#from CyLP.cy.CyCoinIndexedVector cimport CyCoinIndexedVector, CppCoinIndexedVector
from CyLP.cy.CyCoinModel cimport CyCoinModel, CppCoinModel
from CyLP.cy.CyCoinPackedMatrix cimport CyCoinPackedMatrix, CppCoinPackedMatrix
from CyLP.cy.CyCbcModel cimport CyCbcModel, CppICbcModel
from CyLP.python.modeling.CyLPModel import CyLPModel
from CyLP.cy.CyCoinIndexedVector cimport CyCoinIndexedVector, CppCoinIndexedVector

cdef extern from "IClpPrimalColumnPivotBase.h" namespace "IClpSimplex":
    cdef enum Status:
        isFree = 0x00,
        basic = 0x01,
        atUpperBound = 0x02,
        atLowerBound = 0x03,
        superBasic = 0x04,
        isFixed = 0x05

cdef extern from "ClpPrimalColumnPivot.hpp":
    cdef cppclass CppClpPrimalColumnPivot "ClpPrimalColumnPivot":
        pass
    CppClpPrimalColumnPivot *new_ClpPrimalColumnPivot \
                                    "new ClpPrimalColumnPivot" ()

cdef extern from "IClpSimplex.hpp":

    ctypedef int (*runIsPivotAcceptable_t)(void* obj)
    ctypedef int (*varSelCriteria_t)(void* obj, int varInd)
    cdef double cdot(CppCoinIndexedVector* pv1, CppCoinIndexedVector* pv2)

    cdef cppclass CppIClpSimplex "IClpSimplex":
        CppIClpSimplex(PyObject* obj,
                       runIsPivotAcceptable_t runIsPivotAcceptable,
                       varSelCriteria_t runVarSelCriteria)

        void setInteger(int index)
        void copyInIntegerInformation(char* information)

        void setCriteria(varSelCriteria_t vsc)
        void setPrimalColumnPivotAlgorithm(CppClpPrimalColumnPivot* choice)
        int readMps(char*, int keepNames, int ignoreErrors)
        void loadQuadraticObjective(CppCoinPackedMatrix* matrix) 
        int primal(int ifValuesPass, int startFinishOptions)
        int dual(int ifValuesPass, int startFinishOptions)
        int initialSolve()
        int initialPrimalSolve()
        int initialDualSolve()
        void setPerturbation(int value)
        double* djRegion()
        int getNumCols()
        int getNumRows()
        Status getStatus(int sequence)
        double objectiveValue()
        int numberIterations()
        int* QP_ComplementarityList
        int* QP_BanList
        int QP_ExistsBannedVariable

        void useCustomPrimal(int customPrimal)
        int getUseCustomPrimal()

        void setObjectiveCoefficient(int elementIndex, double elementValue )
        void resize(int newNumberRows, int newNumberColumns)

        void setComplementarityList(int* cl)

        void addRow(int numberInRow,
                    int * columns,
                    double * elements,
                    double rowLower,
                    double rowUpper)

        void addColumn(int numberInColumn,
                int * rows,
                double * elements,
                double columnLower,
                double  columnUpper,
                double  objective)

        #number is the number of columns to be added
        void addColumns(int number,
                        double * columnLower,
                        double * columnUpper,
                        double * objective,
                        int * columnStarts,
                        int * rows,
                        double * elements)

        #number is the number of rows to be added
        void addRows(int number,
                        double * rowLower,
                        double * rowUpper,
                        int * rowStarts,
                        int * columns,
                        double * elements)

        void getBInvACol(int col, double* vec)
        void getACol(int ncol, CppCoinIndexedVector * colArray)
        void getRightHandSide(double* righthandside)

        void setColumnUpper(int elementIndex, double elementValue)
        void setColumnLower(int elementIndex, double elementValue)
        void setRowUpper(int elementIndex, double elementValue)
        void setRowLower(int elementIndex, double elementValue)

        double* primalColumnSolution()
        double* dualColumnSolution()
        double* primalRowSolution()
        double* dualRowSolution()
        int status()

        bint flagged(int sequence)
        void setFlagged(int varInd)

        double currentDualTolerance()
        double largestDualError()

        int pivotRow()
        void setPivotRow(int v)

        int sequenceIn()
        void setSequenceIn(int v)

        double dualTolerance()
        double* rowUpper()
        double* rowLower()
        int numberRows()
        int* ComplementarityList()
        int * pivotVariable()
        #void computeDuals()

        #methods that return nunmpy arrays from c (double*  ,...)
        PyObject* getReducedCosts()
        void setReducedCosts(double* rc)
        PyObject* getStatusArray()
        PyObject* getComplementarityList()
        PyObject* getPivotVariable()

        PyObject* getPrimalRowSolution()
        PyObject* getPrimalColumnSolution()
        PyObject* getPrimalColumnSolutionAll()
        PyObject* getSolutionRegion()
        PyObject* getDualRowSolution()
        PyObject* getDualColumnSolution()

        PyObject* filterVars(PyObject*)

        void vectorTimesB_1(CppCoinIndexedVector* vec)
        void transposeTimesSubset(int number, int* which,
                                  double* pi, double* y)
        void transposeTimesSubsetAll(int number, long long int* which,
                                     double* pi, double* y)

        CppIClpSimplex* preSolve(CppIClpSimplex* si,
                              double feasibilityTolerance,
                              bint keepIntegers,
                              int numberPasses,
                              bint dropNames,
                              bint doRowObjective)

        int loadProblem(CppCoinModel * modelObject, int tryPlusMinusOne)
        void loadProblem(CppCoinPackedMatrix* matrix,
		                  double* collb,  double* colub,   
		                  double* obj,
		                  double* rowlb,  double* rowub,
		                  double * rowObjective)

        void setComplement(int var1, int var2)

        void replaceMatrix(CppCoinPackedMatrix* matrix, bint deleteCurrent)

        double getCoinInfinity()

        void setColumnUpperArray(double* columnUpper)
        void setColumnLowerArray(double* columnLower)
        void setRowUpperArray(double* rowUpper)
        void setRowLowerArray(double* rowLower)
        void setObjectiveArray(double* objective, int numberColumns)

        int writeMps(char* filename, int formatType, int numberAcross,
                     double objSense)

        void setVariableName(int varInd, char* name)

        int partialPrice(int start, int end, int* numberWanted)

        int varIsFree(int ind)
        int varBasic(int ind)
        int varAtUpperBound(int ind)
        int varAtLowerBound(int ind)
        int varSuperBasic(int ind)
        int varIsFixed(int ind)

        #int argWeightedMax(PyObject* arr, PyObject* whr, double weight)
        int argWeightedMax(PyObject* arr, PyObject* arr_ind, PyObject* w,
                            PyObject* w_ind)

        CppICbcModel* getICbcModel()


cdef class CyClpSimplex:
    '''
    This is the documentation of CyClpSimpelx in the pyx class
    '''

    cpdef CppIClpSimplex *CppSelf
    cpdef vars
    cdef object varSelCriteria
    cdef CyCoinModel coinModel
    cdef object cyLPModel
    cdef object Hessian

    #cdef void prepareForCython(self, int useCustomPrimal)
    cdef setCppSelf(self,  CppIClpSimplex* s)

    cdef CyClpPrimalColumnPivotBase cyPivot
    #cdef CppICbcModel* cbcModel
    #cdef object nodeCompareObject
    #cdef cbcModelExists
    #cdef object pivotMethodObject
    #cdef object isPivotAcceptable_func

    cpdef int readMps(self, char* filename, int keepNames=*,
                      int ignoreErrors=*)

    cdef setPrimalColumnPivotAlgorithm(self, void* choice)
    cdef double* primalColumnSolution(self)
    cdef double* dualColumnSolution(self)
    cdef double* primalRowSolution(self)
    cdef double* dualRowSolution(self)
    cdef double* rowLower(self)
    cdef double* rowUpper(self)

    #methods that return numpy arrays from c (double*  ,...)
    cpdef getReducedCosts(self)
    cpdef getStatusArray(self)
    cpdef getComplementarityList(self)
    cpdef getPivotVariable(self)

    cpdef filterVars(self, inds)

    cpdef getVarStatus(self, int sequence)

    cdef primalRow(self, CppCoinIndexedVector*,
                                CppCoinIndexedVector*,
                                CppCoinIndexedVector*,
                                CppCoinIndexedVector*,
                                int)

    #cdef void CLP_getBInvACol(self, int col, double* vec)
    #cdef void CLP_getRightHandSide(self, double* righthandside)

    cpdef getACol(self, int ncol, CyCoinIndexedVector colArray)

    #cdef void CLP_setComplementarityList(self, int*)
    cdef int* ComplementarityList(self)
    cdef int* pivotVariable(self)

    cpdef vectorTimesB_1(self, CyCoinIndexedVector vec)

    #cpdef int loadProblem(self, CyCoinModel modelObject, int tryPlusMinusOne=*)

    #cpdef getPrimalConstraintSolution(self)
    #cpdef getPrimalVariableSolution(self)
    #cpdef getDualConstraintSolution(self)
    #cpdef getDualVariableSolution(self)
    #cpdef createComplementarityList(self)

    cpdef setVariableName(self, varInd, name)

cdef class VarStatus:
    pass
cpdef cydot(CyCoinIndexedVector v1, CyCoinIndexedVector v2)

