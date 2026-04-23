Épico 2 — IA para Identificação de Layouts

1. Acesse: teachablemachine.withgoogle.com
2. Clique em "Imagem" → "Modelo de imagem padrão"
3. Crie classes: ex. "Layout A", "Layout B", "Layout C"
4. Para cada classe: clique "Webcam" e tire ~50 fotos de cada croqui
   (ou use "Carregar" para subir fotos já salvas)
5. Clique "Treinar modelo" — aguarda ~2 minutos
6. Clique "Exportar modelo" → aba "TensorFlow Lite"
7. Baixa o .zip, extrai: você terá model.tflite e labels.txt
8. Cole esses dois arquivos em: assets/modelo/
