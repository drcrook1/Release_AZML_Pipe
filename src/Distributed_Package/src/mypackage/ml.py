import json
import os

class Awesome_ML_Model():
    model = None
    version = None

    def get_model_location(self):
        path = os.path.dirname(os.path.realpath(__file__))
        return os.path.join(path, "ml_assets/awesome_model.json")

    def load_model(self):
        loaded_json = json.load(self.get_model_location())
        self.version = loaded_json["version"]
        self.model = loaded_json["weights"]
        return True