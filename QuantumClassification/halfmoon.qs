 namespace Microsoft.Quantum.Kata.QuantumClassification {
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.MachineLearning;
    open Microsoft.Quantum.Math;

    function WithProductKernel(scale : Double, sample : Double[]) : Double[] {
        return sample + [scale * Fold(TimesD, 1.0, sample)];
    }

    function Preprocessed(samples : Double[][]) : Double[][] {
        let scale = 1.0;

        return Mapped(
            WithProductKernel(scale, _),
            samples
        );
    }

    function HalfMoonClassifierStructure() : ControlledRotation[] {
        return [
            ControlledRotation((0, new Int[0]), PauliX, 4),
            ControlledRotation((0, new Int[0]), PauliZ, 5),
            ControlledRotation((1, new Int[0]), PauliX, 6),
            ControlledRotation((1, new Int[0]), PauliZ, 7),
            ControlledRotation((0, [1]), PauliX, 0),
            ControlledRotation((1, [0]), PauliX, 1),
            ControlledRotation((1, new Int[0]), PauliZ, 2),
            ControlledRotation((1, new Int[0]), PauliX, 3)
        ];
    }

    operation TrainHalfMoonModel(
        trainingVectors : Double[][],
        trainingLabels : Int[],
        initialParameters : Double[][],
        mode : Int,
        auxil: Double[]
    ) : (Double[], Double) {
        let samples = Mapped(
            LabeledSample,
            Zip(Mapped(FeaturesPreprocess(mode, auxil, _), trainingVectors), trainingLabels)
        );
        Message("Ready to train.");
        let (optimizedModel, nMisses) = TrainSequentialClassifier(
            Mapped(
                SequentialModel(HalfMoonClassifierStructure(), _, 0.0),
                initialParameters
            ),
            samples,
            DefaultTrainingOptions()
                w/ LearningRate <- 0.1
                w/ MinibatchSize <- 15
                w/ Tolerance <- 0.005
                w/ NMeasurements <- 10000
                w/ MaxEpochs <- 20
                w/ VerboseMessage <- Message,
            DefaultSchedule(trainingVectors),
            DefaultSchedule(trainingVectors)
        );
        Message($"Training complete, found optimal parameters: {optimizedModel::Parameters}");
        return (optimizedModel::Parameters, optimizedModel::Bias);
    }

    operation ValidateHalfMoonModel(
        validationVectors : Double[][],
        validationLabels : Int[],
        parameters : Double[],
        bias : Double,
        mode : Int,
        auxil: Double[]
    ) : Double {
        let samples = Mapped(
            LabeledSample,
            Zip(Mapped(FeaturesPreprocess(mode, auxil, _), validationVectors), validationLabels)
        );
        let tolerance = 0.005;
        let nMeasurements = 10000;
        let results = ValidateSequentialClassifier(
            SequentialModel(HalfMoonClassifierStructure(), parameters, bias),
            samples,
            tolerance,
            nMeasurements,
            DefaultSchedule(validationVectors)
        );
        return IntAsDouble(results::NMisclassifications) / IntAsDouble(Length(samples));
    }

    operation ClassifyHalfMoonModel(
        samples : Double[][],
        parameters : Double[],
        bias : Double,
        tolerance  : Double,
        nMeasurements : Int,
        mode : Int,
        auxil: Double[]
    )
    : Int[] {
        let model = Default<SequentialModel>()
            w/ Structure <- HalfMoonClassifierStructure()
            w/ Parameters <- parameters
            w/ Bias <- bias;
        let features = Mapped(FeaturesPreprocess(mode, auxil, _), samples);
        let probabilities = EstimateClassificationProbabilities(
            tolerance, model,
            features, nMeasurements
        );
        return InferredLabels(model::Bias, probabilities);
    }
 }