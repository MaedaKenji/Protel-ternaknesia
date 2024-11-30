const { DecisionTreeClassifier } = require('ml-cart');
const data = require('./data.json');

function trainDecisionTree() {
    // Data preparation
    const features = data.map(item => [
        item.hijauan_weight,
        item.sentrat_weight,
        item.stress_level,
        item.health_status
    ]);
    const labels = data.map(item => item.optimal);

    // Decision Tree Model
    const decisionTree = new DecisionTreeClassifier();
    decisionTree.train(features, labels);

    return decisionTree;
}

function predict(decisionTree, sample) {
    const prediction = decisionTree.predict([sample]);
    return prediction[0];
}

module.exports = { trainDecisionTree, predict };
