This instruction is for both onnx and tflite models.
<br>

## Classes
0: Fake <br>
1: Real <br><hr>

## Input shape
(1, 3, 80, 80)<br>Where <br>(batch size[variable], channel[fixed], width[fixed], hight[fixed])
<br><hr>

## Normalize (Optional)
mean = (0.5, 0.5, 0.5)<br>
std = (0.5, 0.5, 0.5)
<br><hr>

## N.B.
This is a multiclass classification model (though number of classes is 2). The model returns probability of 2 classes. For example, [0.45, 0.55],  in this case the model's prediction is **Real**. 