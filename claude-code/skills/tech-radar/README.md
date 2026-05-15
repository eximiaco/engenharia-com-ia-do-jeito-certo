# tech-radar skill

## Dependência: `radar-html` CLI

Para gerar o HTML do radar, esta skill requer o CLI `radar-html` instalado localmente.

O CLI está disponível no fork:

```
https://github.com/jnerytech/build-your-own-radar
branch: feature/cli
```

### Instalação

```bash
git clone -b feature/cli https://github.com/jnerytech/build-your-own-radar
cd build-your-own-radar
npm install
npm run build:standalone
npm link
```

Após isso, `radar-html --version` deve retornar a versão instalada.
