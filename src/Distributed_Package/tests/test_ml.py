from mypackage.ml import Awesome_ML_Model

class TestAwesomeModel(object):
    """
    Test Suite against the awesome model
    """

    def test_load_model(self):
        model = Awesome_ML_Model()
        model.load_model()
        assert(model.version is not None)
        assert(model.model is not None)