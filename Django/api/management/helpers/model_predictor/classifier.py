
def find_category(prediction: float):
    if prediction >= 0 and prediction < 0.1:
        return 'nf'
    elif prediction < 33.02 and prediction >= 0.1:
        return 'patv'
    elif prediction < 66.04 and prediction >= 33.02:
        return 'nplv'
    elif prediction > 66.04:
        return 'npatv'
    else:
        return 'inv'