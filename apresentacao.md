
Épico 1:

"O usuário exporta a BOM (lista de materiais) do Inventor como CSV. Nosso app lê esse arquivo, 
valida os dados,campos vazios e quantidades inválidas
e gera um Excel formatado automaticamente. 
Eliminamos o processo manual de copiar linha por linha."

Épico 2:

"Treinamos um modelo de classificação de imagens com o Teachable Machine do Google, 
sem precisar escrever código Python. O modelo aprende os padrões visuais de cada layout. 
No app, o projetista tira uma foto do croqui e recebe imediatamente uma 
sugestão de qual layout usar como base, com o percentual de confiança."

Arquitetura,desenhar no quadro:

[Inventor] → exporta CSV → [App Flutter] → valida → gera [Excel]

[Croqui físico] → câmera → [App Flutter] → TFLite → sugere [Layout X]
