## 🌐 Passo 2 de 4: crie a sua página

Agora vamos criar um site de verdade: uma página sobre você.

1. Na página inicial do repositório, clique em **Add file** → **Create new file**
2. No nome do arquivo, escreva exatamente: `index.html`
3. Cole este código e troque pelos seus dados:

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Sobre mim</title>
  <style>
    body { margin: 0; min-height: 100vh; display: grid; place-items: center; padding: 16px; box-sizing: border-box;
           font-family: system-ui, sans-serif; color: #1f2328;
           background: linear-gradient(135deg, #dff6e8, #e8f0ff); }
    .cartao { max-width: 460px; background: #fff; padding: 32px 28px; border-radius: 20px; text-align: center;
              box-shadow: 0 10px 30px rgba(0, 0, 0, .12); }
    .emoji { font-size: 3.5rem; }
    h1 { margin: 8px 0; color: #1a7f37; }
    .curso { font-weight: 600; color: #57606a; }
    .botao { display: inline-block; margin-top: 12px; padding: 10px 20px; border-radius: 999px;
             background: #1a7f37; color: #fff; text-decoration: none; font-weight: 600; }
  </style>
</head>
<body>
  <main class="cartao">
    <div class="emoji">👋</div>
    <h1>Olá, eu sou Seu Nome!</h1>
    <p class="curso">Estudante de Seu Curso · Faculdade de Tecnologia e Inovação Senac DF</p>
    <p>Este é o meu primeiro site publicado no GitHub. 🚀</p>
    <a class="botao" href="https://github.com/">Meu GitHub</a>
  </main>
</body>
</html>
```

> ✏️ Troque **Seu Nome** e **Seu Curso** pelos seus dados e, no botão, troque `https://github.com/` pelo endereço do seu perfil. Se quiser, mude também o emoji 👋 e as cores (`#1a7f37` é o verde).

4. Clique em **Commit changes...** e confirme

⏳ Fico de olho!
