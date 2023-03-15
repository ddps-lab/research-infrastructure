import numpy as np
import bentoml
from bentoml.io import NumpyNdarray, Image
from PIL.Image import Image as PILImage
from torchvision.models import resnet50, ResNet50_Weights

weights = ResNet50_Weights.DEFAULT
model = resnet50(weights=weights)

model.eval()


saved_model = bentoml.pytorch.save_model(
    "bentoml_resnet50", # model name in the local model store
    model, # model instance being saved
)

print(f"Model saved: {saved_model}")

runner = bentoml.pytorch.get("bentoml_resnet50").to_runner()

svc = bentoml.Service("pytorch_resnet50", runners=[runner])

@svc.api(input=Image(), output=NumpyNdarray(dtype="int64"))
def predict(input_img: PILImage):
    img_arr = np.array(input_img)/255.0
    input_arr = np.expand_dims(img_arr, 0).astype("float32")
    output_tensor = runner.predict.run(input_arr)
    return output_tensor.numpy()
