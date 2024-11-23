from enum import Enum


class PredictionResult(Enum):
    POSITIVE = 'positive'
    NEGATIVE = 'negative'
    INVALID = 'invalid'
