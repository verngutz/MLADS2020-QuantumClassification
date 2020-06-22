
// This file is submitted by the participant
namespace Solution {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.MachineLearning;

    // The operation that the participant has to implement
    // Has to return three things: 
    //  1) the feature engineering to perform (as an index in the array of feature engineering functions and an array of parameters to be used with it)
    //  2) circuit structure (as an array of ControlledRotation)
    //  3) and training results (circuit parameters + bias)
    //
    // The features engineering is built-in and cannot be tweaked by the participant's solution, only chosen from the list 
    // (see quantum-checker.qs for the list of available feature engineering functions)
    //
    operation Solve () : ((Int, Double[]), ControlledRotation[], (Double[], Double)) {
        return ((1, [0.5]),
                Microsoft.Quantum.Kata.QuantumClassification.HalfMoonClassifierStructure(),
                ([0.5863967030651399, 3.43904868303777, 0.8090238895561211, 2.8894948932009186, 1.0886860774404312, 3.084281393912131, 2.1849878087190313, 5.585155680162918], -0.1721491169297289));
    }


}