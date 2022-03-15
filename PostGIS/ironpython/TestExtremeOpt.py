# http://www.extremeoptimization.com/Features.aspx
import clr
import System
import random
clr.AddReference("Extreme.Numerics.Net35")
clr.AddReference("Extreme.Generic.Net35")

from Extreme.Statistics.Random import *
from System import Array
import Extreme.Mathematics.Generic

# The optimization classes reside in the
# Extreme.Mathematics.Optimization namespace.
from Extreme.Mathematics.Optimization import *
# Function delegates reside in the Extreme.Mathematics
# namespace.
from Extreme.Mathematics import *

# Vectors reside in the Extreme.Mathematics.LinearAlgebra
# namespace.
from Extreme.Mathematics.LinearAlgebra import *
from math import *
# The numerical integration classes reside in the
# Extreme.Mathematics.Calculus namespace.
from Extreme.Mathematics.Calculus import *
from Extreme.Mathematics.Algorithms import *

from Extreme.Statistics import *
from Extreme.Statistics.Distributions import *

from math import log, exp

def testmatrix():
    m = Matrix(2, 2, 1.2)
    n = Matrix(2,1)
    m1=Matrix(1000,40)
    for i in range(0,1000):
        for j in range(0,40):
            m1[i,j]= random.random()*100
    print m1
    n[0,0] = 4
    print m
    print n
    x1=m * n
    x2=n.Transpose() * m
    print x1
    print x2

# The famous Rosenbrock test function.
def fRosenbrock(x):
	p = (1-x[0])
	q = x[1] - x[0]*x[0]
	return p*p + 105 * q*q

# Gradient of the Rosenbrock test function.
def gRosenbrock(x, f):
	# Always assume that the second argument may be null:
	if f == None:
		f = Vector.Create(2)
	p = (1-x[0])
	q = x[1] - x[0]*x[0]
	f[0] = -2*p - 420*x[0]*q
	f[1] = 210*q
	return f

def gradientOptimisation():
    """
    <Script>
    <Author>admin</Author>
    <Description>Please enter script description here</Description>
    </Script>
    """
    # The gradient of the objective function can be supplied either
    # as a MultivariateVectorFunction delegate, or a
    # MultivariateVectorFunction delegate. The former takes
    # one vector argument and returns a vector. The latter
    # takes a second vector argument, which is an existing
    # vector that is used to return the result.

    # The initial values are supplied as a vector:
    initialGuess = Vector.Create(-1.2, 1)
    # The actual solution is [1, 1].

    #
    # Quasi-Newton methods: BFGS and DFP
    #

    # For most purposes, the quasi-Newton methods give
    # excellent results. There are two variations: DFP and
    # BFGS. The latter gives slightly better results.

    # Which method is used, is specified by a constructor
    # parameter of type QuasiNewtonMethod:
    bfgs = QuasiNewtonOptimizer(QuasiNewtonMethod.Bfgs)

    bfgs.InitialGuess = initialGuess
    bfgs.ExtremumType = ExtremumType.Minimum

    # Set the ObjectiveFunction:
    bfgs.ObjectiveFunction = fRosenbrock
    # Set either the GradientFunction or FastGradientFunction:
    bfgs.FastGradientFunction = gRosenbrock
    # The FindExtremum method does all the hard work:
    bfgs.FindExtremum()

    print "BFGS Method:"
    print "  Solution:", bfgs.Extremum
    print "  Estimated error:", bfgs.EstimatedError
    print "  # iterations:", bfgs.IterationsNeeded
    # Optimizers return the number of function evaluations
    # and the number of gradient evaluations needed:
    print "  # function evaluations:", bfgs.EvaluationsNeeded
    print "  # gradient evaluations:", bfgs.GradientEvaluationsNeeded

    #
    # Conjugate Gradient methods
    #

    # Conjugate gradient methods exist in three variants:
    # Fletcher-Reeves, Polak-Ribiere, and positive Polak-Ribiere.

    # Which method is used, is specified by a constructor
    # parameter of type ConjugateGradientMethod:
    cg = ConjugateGradientOptimizer(ConjugateGradientMethod.PositivePolakRibiere)
    # Everything else works as before:
    cg.ObjectiveFunction = fRosenbrock
    cg.FastGradientFunction = gRosenbrock
    cg.InitialGuess = initialGuess
    cg.FindExtremum()

    print "Conjugate Gradient Method:"
    print "  Solution:", cg.Extremum
    print "  Estimated error:", cg.EstimatedError
    print "  # iterations:", cg.IterationsNeeded
    print "  # function evaluations:", cg.EvaluationsNeeded
    print "  # gradient evaluations:", cg.GradientEvaluationsNeeded

    #
    # Powell's method
    #

    # Powell's method is a conjugate gradient method that
    # does not require the derivative of the objective function.
    # It is implemented by the PowellOptimizer class:
    pw = PowellOptimizer()
    pw.InitialGuess = initialGuess
    # Powell's method does not use derivatives:
    pw.ObjectiveFunction = fRosenbrock
    pw.FindExtremum()

    print "Powell's Method:"
    print "  Solution:", pw.Extremum
    print "  Estimated error:", pw.EstimatedError
    print "  # iterations:", pw.IterationsNeeded
    print "  # function evaluations:", pw.EvaluationsNeeded
    print "  # gradient evaluations:", pw.GradientEvaluationsNeeded

    #
    # Nelder-Mead method
    #

    # Also called the downhill simplex method, the method of Nelder 
    # and Mead is useful for functions that are not tractable 
    # by other methods. For example, other methods
    # may fail if the objective function is not continuous.
    # Otherwise it is much slower than other methods.

    # The method is implemented by the NelderMeadOptimizer class:
    nm = NelderMeadOptimizer()

    # The class has three special properties, that help determine
    # the progress of the algorithm. These parameters have
    # default values and need not be set explicitly.
    nm.ContractionFactor = 0.5
    nm.ExpansionFactor = 2
    nm.ReflectionFactor = -2

    # Everything else is the same.
    nm.SolutionTest.AbsoluteTolerance = 1e-15
    nm.InitialGuess = initialGuess
    # The method does not use derivatives:
    nm.ObjectiveFunction = fRosenbrock
    nm.FindExtremum()

    print "Nelder-Mead Method:"
    print "  Solution:", nm.Extremum
    print "  Estimated error:", nm.EstimatedError
    print "  # iterations:", nm.IterationsNeeded
    print "  # function evaluations:", nm.EvaluationsNeeded


def testMILP():
    # Illustrates solving mixed integer programming problems
    # using the classes in the Extreme.Mathematics.Optimization
    # namespace of the Extreme Optimization Numerical Libraries for .NET.

    # In this QuickStart sample, we'll use the Mixed Integer
    # programming capabilities to solve Sudoku puzzles.
    # The rules of Sudoku will be4 expressed in terms of
    # linear constraints on binary variables.

    # First, create an empty linear program.
    lp = LinearProgram()

    # Create an array of binary variables that indicate whether
    # the cell at a specific row and column contain a specific digit.
    # - The first index corresponds to the row.
    # - The second index corresponds to the column.
    # - The third index corresponds to the digit.
    variables = Array.CreateInstance(LinearProgramVariable, 9, 9, 9)

    # Create a binary variable for each digit in each row and column.
    # The AddBinaryVariable method creates a variable that can have values of 0 or 1.
    for row in range(9):
        for column in range(9):
            for digit in range(9):
                variables[row, column, digit] = lp.AddBinaryVariable("x{0}{1}{2}".format(row, column, digit), 0.0)

    # To add integer variables, you can use the AddIntegerVariable method.
    # To add real variables, you can use the AddVariable method.

    # Now add constraints that represent the rules of Sudoku.

    # There are 4 rules in Sudoku. They are all of the kind
    # where only one of a certain set of combinations 
    # of (row, column, digit) can occur at the same time.
    # We can express this by stating that the sum of the corresponding
    # binary variables must be one.

    # AddConstraints is a helper function defined below.
    # For each combination of the first two arguments, 
    # it builds a constraint by iterating over the third argument.
    coefficients = Vector.Create([ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 ])
    def AddConstraints(lp, variable):
        for i in range(9):
            for j in range(9):
                variables = Array.CreateInstance(LinearProgramVariable, 9)
                for k in range(9):
                    variables[k] = variable(i, j, k)
                lp.AddLinearConstraint(variables, coefficients, ConstraintType.Equal, 1.0)

    # Rule 1: each posiion contains exactly one digit
    AddConstraints(lp, lambda row, column, digit: variables[row, column, digit])
    # Rule 2: each digit appears once in each row
    AddConstraints(lp, lambda row, digit, column: variables[row, column, digit])
    # Rule 3: each digit appears once in each column
    AddConstraints(lp, lambda column, digit, row: variables[row, column, digit])
    # Rule 4: each digit appears exactly once in each block
    AddConstraints(lp, lambda block, digit, index: \
        variables[3 * (block % 3) + (index % 3), 3 * (block / 3) + (index / 3), digit])

    # We represent the board with a 9x9 sparse matrix.
    # The nonzero entries correspond to the numbers
    # already on the board.

    # Let's see if we can solve "the world's hardest Sudoku" puzzle:
    # http:#www.mirror.co.uk/fun-games/sudoku/2010/08/19/world-s-hardest-sudoku-can-you-solve-dr-arto-inkala-s-puzzle-115875-22496946/
    rows = Array[int]([ 0,0,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,8,8 ])
    columns = Array[int]([ 2,3,0,7,1,4,6,0,5,6,1,4,8,2,3,7,1,3,8,2,7,5,6 ])
    digits = Array[float]([ 5,3,8,2,7,1,5,4,5,3,1,7,6,3,2,8,6,5,9,4,3,9,7 ])
    board = Matrix.CreateSparse(9, 9, rows, columns, digits)

    # Now fix the variables for the for the digits that are already on the board.
    # We do this by setting the lower bound equal to the upper bound:
    for triplet in board.NonzeroComponents:
        variables[triplet.Row, triplet.Column, triplet.Value - 1].LowerBound = 1.0

    # Solve the linear program.
    solution = lp.Solve()

    # Scan the variables and print the digit if the value is 1.
    for row in range(9):
        for column in range(9):
            theDigit = 0
            for digit in range(9):
                if variables[row, column, digit].Value == 1.0:
                    theDigit = digit + 1
                    break
            print theDigit.ToString() if theDigit > 0 else ".",
        print 

def LinearAlgebra():

    # Illustrates solving least squares problems using the 
    # LeastSquaresSolver class in the Extreme.Mathematics.LinearAlgebra 
    # namespace of the Extreme Optimization Mathematics Library
    # for .NET.

    # A least squares problem consists in finding
    # the solution to an overdetermined system of
    # simultaneous linear equations so that the
    # sum of the squares of the error is minimal.
    #
    # A common application is fitting data to a
    # curve. See the CurveFitting sample application
    # for a complete example.

    # Let's start with a general matrix. This will be
    # the matrix a in the left hand side ax=b:
    #mx=Matrix.Create(Array.CreateInstance(float,6,4))
    data=[[1.0,1.0,1.0,1.0], [1.0,2.0,4.0,2.0],[1.0,3.0,9.0,1.0],[1.0,4.0,16.0,2.0],[1.0,5.0,25.0,1.0],[1.0,6.0,36.0,2.0]]
    mx = Array.CreateInstance(float, len(data), len(data[0]))
    for i, row in enumerate(data):
        for j, col in enumerate(row):
            mx[i, j] = col
    a=Matrix.Create(mx)
    #a = Matrix.Create(Array[float][float]([1.0,1.0,1.0,1.0], [1.0,2.0,4.0,2.0],[1.0,3.0,9.0,1.0],[1.0,4.0,16.0,2.0],[1.0,5.0,25.0,1.0],[1.0,6.0,36.0,2.0]))
    # Here is the right hand side:
    b = Vector.Create([1.0, 3.0, 6.0, 11.0, 15.0, 21.0])

    data=[[1,1],[3,2],[6,3],[11,4],[15,5],[21,7]]
    mx = Array.CreateInstance(float, len(data), len(data[0]))
    for i, row in enumerate(data):
        for j, col in enumerate(row):
            mx[i, j] = col
    b2 = Matrix.Create(mx)
    print "a = {0}".format(a.ToString())
    print "b = {0}".format(b.ToString())

    #
    # The LeastSquaresSolver class
    #

    # The following creates an instance of the
    # LeastSquaresSolver class for our problem:
    solver = LeastSquaresSolver(a, b)
    # We can specify the solution method: normal
    # equations or QR decomposition. In most cases, # a QR decomposition is the most desirable:
    solver.SolutionMethod = LeastSquaresSolutionMethod.QRDecomposition
    # The Solve method calculates the solution:
    x = solver.Solve()
    print "x = {0}".format(x.ToString())
    # The Solution property also returns the solution:
    print "x = {0}".format(solver.Solution.ToString())
    # More detailed information is available from
    # additional methods.
    # The values of the right hand side predicted 
    # by the solution:
    print "Predictions = {0}".format(solver.GetPredictions().ToString())
    # The residuals (errors) of the solution:
    print "Residuals = {0}".format(solver.GetResiduals().ToString())
    # The total sum of squares of the residues:
    print "Residual square error =", solver.GetResidualSumOfSquares()

    #
    # Direct normal equations
    #

    # Alternatively, you can create a least squares
    # solution by providing the normal equations
    # directly. This may be useful when it is easy
    # to calculate the normal equations directly.
    # 
    # Here, we'll just calculate the normal equation:
    aTa = SymmetricMatrix.FromOuterProduct(a)
    aTb = b * a # a.Transpose() * b
    # We find the solution by solving the normal equations
    # directly:
    x = aTa.Solve(aTb)
    print "x = {0}".format(x.ToString())
    # However, properties of the least squares solution, such as
    # error estimates and residuals are not available.

def LineCurveFit():
    from System import Array
    from System import Func

    # The curve fitting classes reside in the 
    # Extreme.Mathematics.Curves namespace.
    from Extreme.Mathematics import *
    from Extreme.Mathematics.Curves import *

    #/ Illustrates least squares curve fitting of polynomials and
    #/ other linear functions using the LinearCurveFitter class in the 
    #/ Extreme.Mathematics.Curves namespace of the Extreme
    #/ Optimization Numerical Libraries for .NET.

    # This QuickStart sample illustrates linear least squares
    # curve fitting using polynomials and linear combinations
    # of arbitrary functions.

    # Linear least squares fits are calculated using the
    # LinearCurveFitter class:
    fitter = LinearCurveFitter()

    # We use data from the National Institute for Standards 
    # and Technology's Statistical Reference Datasets library 
    # at http:#www.itl.nist.gov/div898/strd/.

    # Note that, due to round-off error, the results here will not be exactly
    # the same as the NIST results, which were calculated using 500 digits
    # of precision!
    # We use the 'Pontius' dataset, which contains measurement data
    # from the calibration of load cells. The independent variable is the load.
    # The dependent variable is the deflection.
    deflectionData = Vector.Create([ .11019, .21956, .32949, .43899, .54803, .65694, \
        .76562, .87487, .98292, 1.09146, 1.20001, 1.30822, 1.41599, 1.52399, \
        1.63194, 1.73947, 1.84646, 1.95392, 2.06128, 2.16844, .11052, .22018, \
        .32939, .43886, .54798, .65739, .76596, .87474, .98300, 1.09150, \
        1.20004, 1.30818, 1.41613, 1.52408, 1.63159, 1.73965, 1.84696, \
        1.95445, 2.06177, 2.16829 ])
    loadData =Vector.Create([ 150.0, 300.0, 450.0, 600.0, 750.0, 900.0, 1050.0, 1200.0, 1350.0, 1500.0, \
        1650.0, 1800.0, 1950.0, 2100.0, 2250.0, 2400.0, 2550.0, 2700.0, 2850.0, 3000.0, 150.0, 300.0, \
        450.0, 600.0, 750.0, 900.0, 1050.0, 1200.0, 1350.0, 1500.0, 1650.0, 1800.0, 1950.0, 2100.0, \
        2250.0, 2400.0, 2550.0, 2700.0, 2850.0, 3000.0 ])

    # You must supply the curve whose parameters will be
    # fit to the data. The curve must inherit from LinearCombination.
    #
    # Here, we use a quadratic polynomial:
    fitter.Curve = Polynomial(2)

    # The X values go into the XValues property:
    fitter.XValues = loadData
    # ...and Y values go into the YValues property:
    fitter.YValues = deflectionData

    # The Fit method performs the actual calculation:
    fitter.Fit()

    # A Vector containing the parameters of the best fit
    # can be obtained through the
    # BestFitParameters property.
    solution = fitter.BestFitParameters
    # The standard deviations associated with each parameter
    # are available through the GetStandardDeviations method.
    s = fitter.GetStandardDeviations()

    print "Calibration of load cells"
    print "    deflection = c1 + c2*load + c3*load^2 "
    print "Solution:"
    print "c1: {0:20.10e} {1:20.10e}".format(solution[0], s[0])
    print "c2: {0:20.10e} {1:20.10e}".format(solution[1], s[1])
    print "c3: {0:20.10e} {1:20.10e}".format(solution[2], s[2])

    print "Residual sum of squares:", fitter.Residuals.Norm()

    # Now let's redo the same operation, but with observations weighted
    # by 1/Y^2. To do this, we set the WeightFunction property.
    # The WeightFunctions class defines a set of ready-to-use weight functions.
    fitter.WeightFunction = WeightFunctions.OneOverYSquared
    # Refit the curve:
    fitter.Fit()
    solution = fitter.BestFitParameters
    s = fitter.GetStandardDeviations()

    # The solution is slightly different:
    print "Solution (weighted observations):"
    print "c1: {0:20.10e} {1:20.10e}".format(solution[0], s[0])
    print "c2: {0:20.10e} {1:20.10e}".format(solution[1], s[1])
    print "c3: {0:20.10e} {1:20.10e}".format(solution[2], s[2])
    print 

    #
    # Fitting combinations of arbitrary functions
    #

    # The following example estimates the two parameters, c1 and c2
    # in the theoretical model for conductance:
    #     k(T) = 1 / (c1 / T + c2 * T*T)

    temperature = Vector.Create([ 12.2900, 13.7500, 14.8200, 16.1200, 18.0400, 18.6700, \
        20.5200, 22.6800, 25.1500, 27.7200, 30.2400, 33.2100, 36.4800, 39.8600, 50.4000 ])
    conductance = Vector.Create([ 25.3500, 27.8800, 29.9300, 30.4200, 31.0000, 31.9600, \
        32.4700, 30.3300, 31.1400, 27.4600, 23.2900, 20.7200, 17.2400, 14.7100,  9.5000 ])

    # First, we transform the dependent variable:
    y = Vector.Reciprocal(conductance)

    # y is a linear combination of basis functions 1/T and T*T.
    # Create a function basis object:
    basisFunctions = Array[Func[float,float]]([ lambda x: 1 / x, lambda x: x**2 ])
    basis = GeneralFunctionBasis(basisFunctions)

    # Create a LinearCombination curve using this function basis:
    curve = LinearCombination(basis)

    # Set the curve fitter properties:
    fitter.Curve = curve
    fitter.XValues = temperature
    fitter.YValues = y
    # Reset the weights
    fitter.WeightFunction = None
    fitter.WeightVector = None

    # Now compute the solution:
    fitter.Fit()
    solution = fitter.BestFitParameters
    s = fitter.GetStandardDeviations()

    # Print the results
    print "Conductance of copper: k(T) = 1 / (c1/T + c2*T^2)"
    print "Solution:"
    print "c1: {0:20.10e} {1:20.10e}".format(solution[0], s[0])
    print "c2: {0:20.10e} {1:20.10e}".format(solution[1], s[1])

    print "Residual sum of squares:", fitter.Residuals.Norm()

def BasicIntegration():

    #/ Illustrates the basic use of the numerical integration
    #/ classes in the Extreme.Mathematics.Calculus namespace of the Extreme
    #/ Optimization Mathematics Library for .NET.

    # Numerical integration algorithms fall into two
    # main categories: adaptive and non-adaptive.
    # This QuickStart Sample illustrates the use of
    # the non-adaptive numerical integrators.
    #
    # All numerical integration classes derive from
    # NumericalIntegrator. This abstract base class
    # defines properties and methods that are shared
    # by all numerical integration classes.

    #
    # The integrand
    #

    # The function we are integrating must be
    # provided as a Func<double, double>. 
    f = sin
			
    #
    # SimpsonIntegrator
    # 

    # The simplest numerical integration algorithm
    # is Simpson's rule. 
    simpson = SimpsonIntegrator()
    # You can set the relative or absolute tolerance
    # to which to evaluate the integral.
    simpson.RelativeTolerance = 1e-5
    # You can select the type of tolerance using the
    # ConvergenceCriterion property:
    simpson.ConvergenceCriterion = ConvergenceCriterion.WithinRelativeTolerance
    # The Integrate method performs the actual 
    # integration:
    result = simpson.Integrate(sin, 0, 2)
    print "sin(x) on [0,2]"
    print "Simpson integrator:"
    # The result is also available in the Result 
    # property:
    print "  Value:", simpson.Result
    # To see whether the algorithm ended normally, # inspect the Status property:
    print "  Status:", simpson.Status
    # You can find out the estimated error of the result
    # through the EstimatedError property:
    print "  Estimated error:", simpson.EstimatedError
    # The number of iterations to achieve the result
    # is available through the IterationsNeeded property.
    print "  Iterations:", simpson.IterationsNeeded
    # The number of function evaluations is available 
    # through the EvaluationsNeeded property.
    print "  Function evaluations:", simpson.EvaluationsNeeded

    #
    # Gauss-Kronrod Integration
    #

    # Gauss-Kronrod integrators also use a fixed point 
    # scheme, but with certain optimizations in the 
    # choice of points where the integrand is evaluated.

    # The NonAdaptiveGaussKronrodIntegrator uses a
    # succession of 10, 21, 43, and 87 point rules
    # to approximate the integral.
    nagk = NonAdaptiveGaussKronrodIntegrator()
    nagk.Integrate(sin, 0, 2)
    print "Non-adaptive Gauss-Kronrod rule:"
    print "  Value:", nagk.Result
    print "  Status:", nagk.Status
    print "  Estimated error:", nagk.EstimatedError
    print "  Iterations:", nagk.IterationsNeeded
    print "  Function evaluations:", nagk.EvaluationsNeeded
    #
    # Romberg Integration
    #

    # Romberg integration combines Simpson's Rule
    # with a scheme to accelerate convergence.
    # This algorithm is useful for smooth integrands.
    romberg = RombergIntegrator()
    result = romberg.Integrate(sin, 0, 2)
    print "Romberg integration:"
    print "  Value:", romberg.Result
    print "  Status:", romberg.Status
    print "  Estimated error:", romberg.EstimatedError
    print "  Iterations:", romberg.IterationsNeeded
    print "  Function evaluations:", romberg.EvaluationsNeeded
    # However, it breaks down if the integration
    # algorithm contains singularities or 
    # discontinuities.
    #
    # The AdaptiveIntegrator can handle this type
    # of integrand, and many other difficult cases.
    # See the AdvancedIntegration QuickStart sample
    # for details.
    result = romberg.Integrate(lambda x: 0.0 if x <= 0.0 else x ** -0.9 * log(1/x), 0.0, 1.0)
    print "Romberg on hard integrand:"
    print "  Value:", romberg.Result
    print "  Actual value: 100"
    print "  Status:", romberg.Status
    print "  Estimated error:", romberg.EstimatedError
    print "  Iterations:", romberg.IterationsNeeded
    print "  Function evaluations:", romberg.EvaluationsNeeded

    #/ Function that will cause difficulties to the
    #/ simplistic integration algorithms.
    #/ </summary>
    def HardIntegrand(x):

	    # This is put in because some integration rules
	    # evaluate the function at x=0.
	    if x <= 0:
		    return 0
	    return x**-0.9 * log(1/x)

def ContinuousStatistics():
    #/ Demonstrates how to use classes that implement
    #/ continuous probabililty distributions.

    # This QuickStart Sample demonstrates the capabilities of
    # the classes that implement continuous probability distributions.
    # These classes inherit from the ContinuousDistribution class.
    #
    # For an illustration of classes that implement discrete probability
    # distributions, see the DiscreteDistributions QuickStart Sample.
    # 
    # We illustrate the properties and methods of continuous distribution
    # using a Weibull distribution. The same properties and methods
    # apply to all other continuous distributions.

    # 
    # Constructing distributions
    #

    # Most distributions have one or more parameters with different definitions.
    #
    # The location parameter is always related to the mean of the distribution.
    # When omitted, its default value is zero.
    #
    # The scale parameter is always directly related to the standard deviation.
    # A larger scale parameter means that the distribution is wider.
    # When omitted, its default value is one.

    # The Weibull distribution has three constructors. The most complete
    # constructor takes a location, scale, and shape parameter.
    weibull = WeibullDistribution(3, 2, 3)

    #
    # Basic statistics
    #

    # The Mean property returns the mean of the distribution:
    print "Mean:                 {0:.5f}".format(weibull.Mean)

    # The Variance and StandardDeviation are also available:
    print "Variance:             {0:.5f}".format(weibull.Variance)
    print "Standard deviation:   {0:.5f}".format(weibull.StandardDeviation)
    # The inter-quartile range is another measure of scale:
    print "Inter-quartile range: {0:.5f}".format(weibull.InterQuartileRange)

    # As are the skewness:
    print "Skewness:             {0:.5f}".format(weibull.Skewness)

    # The Kurtosis property returns the kurtosis supplement.
    # The Kurtosis property for the normal distribution returns zero.
    print "Kurtosis:             {0:.5f}".format(weibull.Kurtosis)
    print 

    #
    # Distribution functions
    #

    # The (cumulative) distribution function (CDF) is implemented by the
    # DistributionFunction method:
    print "CDF(4.5) =            {0:.5f}".format(weibull.DistributionFunction(4.5))

    # Its complement is the survivor function:
    print "SDF(4.5) =            {0:.5f}".format(weibull.SurvivorDistributionFunction(4.5))

    # While its inverse is given by the InverseDistributionFunction method:
    print "Inverse CDF(0.4) =    {0:.5f}".format(weibull.InverseDistributionFunction(0.4))

    # The probability density function (PDF) is also available:
    print "PDF(4.5) =            {0:.5f}".format(weibull.ProbabilityDensityFunction(4.5))
			
    # The Probability method returns the probability that a variate lies between two values:
    print "Probability(4.5, 5.5) = {0:.5f}".format(weibull.Probability(4.5, 5.5))
    print 

    #
    # Random variates
    #

    # The Sample method returns a single random variate 
    # using the specified random number generator:
    rng = Random.MersenneTwister()
    x = weibull.Sample(rng)
    # The Sample method fills an array or vector with
    # random variates. It has several overloads:
    xVector = Vector.Create(100)
    # 1. Fill all values:
    weibull.Sample(rng, xVector)
    # 2. Fill only a range (start index and length are supplied)
    weibull.Sample(rng, xVector, 20, 50)
    # The same two options are available with a DenseVector
    # instead of a double array.

    # The GetExpectedHistogram method returns a Histogram that contains the
    # expected number of samples in each bin, given the total number of samples.
    # The bins are specified by lower and upper bounds and number of bins:
    h = weibull.GetExpectedHistogram(3.0, 10.0, 5, 100)
    print "Expected distribution of 100 samples:"
    for bin in h.Bins:
	    print "Between {0} and {1} -> {2}".format(bin.LowerBound, bin.UpperBound, bin.Value)
    print 

    # or by supplying an array of boundaries:
    h = weibull.GetExpectedHistogram(Array[float]([ 3.0, 5.2, 7.4, 9.6, 11.8 ]), 100)
    print "Expected distribution of 100 samples:"
    for bin in h.Bins:
	    print "Between {0} and {1} -> {2}".format(bin.LowerBound, bin.UpperBound, bin.Value)

def NonLinearProgrammingOptimisation():

    # Illustrates solving nonlinear programming problems
    # using the classes in the Extreme.Mathematics.Optimization
    # namespace of the Extreme Optimization Numerical Libraries for .NET.

    # This QuickStart Sample illustrates the two ways to create a Nonlinear Program.

    # The first is in terms of matrices. The coefficients
    # are supplied as a matrix. The cost vector, right-hand side
    # and constraints on the variables are supplied as a vector.

    print "Problem with only linear constraints:"

    # The variables are the concentrations of each chemical compound:
    # H, H2, H2O, N, N2, NH, NO, O, O2, OH

    # The objective function is the free energy, which we want to minimize:
    c = Vector.Create([ \
        -6.089, -17.164, -34.054, -5.914, -24.721, \
        -14.986, -24.100, -10.708, -26.662, -22.179 ])
    objectiveFunction = lambda x: x.DotProduct.Overloads[DenseVector](c + Vector.Log(x).Add(-log(x.GetSum())))
    def g1(x,y): 
        s = x.GetSum()
        (c + Vector.Log(x).Add(1 - log(s)) - x / s).CopyTo(y)
        return y
    objectiveGradient = g1

    # The constraints are the mass balance relationships for each element. 
    # The rows correspond to the elements H, N, and O.
    # The columns are the index of the variable.
    # The value is the number of times the element occurs in the
    # compound corresponding to the variable:
    # H, H2, H2O, N, N2, NH, NO, O, O2, OH
    # All this is stored in a sparse matrix, so 0 values are omitted: 
    A = Matrix.CreateSparse(3, 10, \
        Array[int]([ 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 2 ]), \
        Array[int]([ 0, 1, 2, 5, 9, 3, 4, 5, 6, 2, 6, 7, 8, 9 ]), \
        Array[float]([ 1, 2, 2, 1, 1, 1, 2, 1, 1, 1, 1, 1, 2, 1 ]))
    # The right-hand sides are the atomic weights of the elements
    # in the mixture.
    b = Vector.Create([ 2.0, 1.0, 1.0 ])

    # The number of moles for each compound must be positive.
    l = Vector.CreateConstant(10, 1e-6)
    u = Vector.CreateConstant(10, float.PositiveInfinity)
            
    # We create the nonlinear program with the specified constraints:
    # Because we have variable bounds, we use the constructor
    # that lets us do this.
    nlp1 = NonlinearProgram(objectiveFunction, objectiveGradient, A, b, b, l, u)

    # We could add more (linear or nonlinear) constraints here, # but this is all we have in our problem.

    nlp1.InitialGuess = Vector.CreateConstant(10, 0.1)
    solution = nlp1.Solve()
    print "Solution: {0}".format(['%.3f' % val for val in solution.StorageArray])
    print "Optimal value:   {0:.5f}".format(nlp1.OptimalValue)
    print "# iterations:", nlp1.SolutionReport.IterationsNeeded
    print 

    # The second method is building the nonlinear program from scratch.

    print "Problem with nonlinear constraints:"

    # We start by creating a nonlinear program object. We supply 
    # the number of variables in the constructor.
    nlp2 = NonlinearProgram(2)

    nlp2.ObjectiveFunction = lambda x: exp(x[0]) * (4 * x[0] * x[0] + 2 * x[1] * x[1] + 4 * x[0] * x[1] + 2 * x[1] + 1)
    def g2(x, y):
        exp1 = exp(x[0]) 
        y[0] = exp1 * (4 * x[0] * x[0] + 2 * x[1] * x[1] + 4 * x[0] * x[1] + 8 * x[0] + 6 * x[1] + 1) 
        y[1] = exp1 * (4 * x[0] + 4 * x[1] + 2) 
        return y
    nlp2.ObjectiveGradient = g2

    # Add constraint x0*x1 - x0 -x1 <= -1.5
    def c2gradient(x, y):
        y[0] = x[1] - 1
        y[1] = x[0] - 1 
        return y
    nlp2.AddNonlinearConstraint(lambda x: x[0] * x[1] - x[0] - x[1] + 1.5, \
        ConstraintType.LessThanOrEqual, 0.0, c2gradient)
            
    # Add constraint x0*x1 >= -10
    # If the gradient is omitted, it is approximated using divided differences.
    nlp2.AddNonlinearConstraint(lambda x: x[0] * x[1], ConstraintType.GreaterThanOrEqual, -10.0)

    nlp2.InitialGuess = Vector.Create([ -1.0, 1.0 ])
            
    solution = nlp2.Solve()
    print "Solution: {0:.6f}".format(solution)
    print "Optimal value:   {0:.6f}".format(nlp2.OptimalValue)
    print "# iterations:", nlp2.SolutionReport.IterationsNeeded

def TestExtremeComponents():
    """
    <Script>
    <Author>Extreme TestSuite</Author>
    <Description>Test all the module components</Description>
    </Script>
    """
    try:
        print 'MILP Optimisation'
        testMILP()
        print 'Gradient Optimisation'
        gradientOptimisation()
        print 'Linear Curve Fitting'        
        LineCurveFit()
        print 'Running Basic Integration'
        BasicIntegration()
        
        print 'Running Continuous Statistics Example'
        ContinuousStatistics()
        
        print 'Running Non Linear Programming Optimisation'
        NonLinearProgrammingOptimisation()
        
        print 'Running Linear Algebra'
        LinearAlgebra()
        print 'Test Completed'
    except System.Exception, e:
        print 'Error: ' + e.Message

TestExtremeComponents()
