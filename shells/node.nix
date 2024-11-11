{ pkgs }:

pkgs.mkShell {
  name = "nodejs";
  buildInputs = with pkgs; [
    nodejs
    nodePackages.typescript
    nodePackages.ts-node
    nodePackages.typescript-language-server
    yarn
    nodePackages.pnpm
  ];

  shellHook = ''
        # Initialize project if it doesn't exist
        if [ ! -f "package.json" ]; then
          echo "Creating new TypeScript project..."

          # Initialize package.json
          cat > package.json << 'EOL'
    {
      "name": "typescript-project",
      "version": "1.0.0",
      "description": "",
      "main": "dist/index.js",
      "scripts": {
        "start": "ts-node src/index.ts",
        "build": "tsc",
        "dev": "ts-node-dev --respawn src/index.ts",
        "test": "jest",
        "lint": "eslint . --ext .ts"
      },
      "keywords": [],
      "author": "",
      "license": "MIT"
    }
    EOL

          # Initialize TypeScript configuration
          cat > tsconfig.json << 'EOL'
    {
      "compilerOptions": {
        "target": "es2020",
        "module": "commonjs",
        "lib": ["es2020"],
        "strict": true,
        "esModuleInterop": true,
        "skipLibCheck": true,
        "forceConsistentCasingInFileNames": true,
        "outDir": "dist",
        "rootDir": "src"
      },
      "include": ["src/**/*"],
      "exclude": ["node_modules", "**/*.spec.ts"]
    }
    EOL

          # Create src directory and index.ts
          mkdir -p src
          cat > src/index.ts << 'EOL'
    function greeting(): string {
      return `Hello, World`;
    }

    console.log(greeting('World'));
    EOL

          # Create a basic .gitignore
          cat > .gitignore << 'EOL'
    # Dependencies
    node_modules/
    .pnp
    .pnp.js

    # Production
    dist/
    build/

    # Debug
    npm-debug.log*
    yarn-debug.log*
    yarn-error.log*

    # Environment variables
    .env
    .env.local
    .env.development.local
    .env.test.local
    .env.production.local

    # IDE
    .vscode/
    .idea/
    *.swp
    *.swo
    EOL

          # Initialize git repository if git is available
          if command -v git >/dev/null 2>&1; then
            git init
          fi

          # Install dependencies
          echo "Installing dependencies..."
          npm install --save-dev typescript ts-node ts-node-dev @types/node eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin jest @types/jest ts-jest

          # Initialize ESLint configuration
          cat > .eslintrc.json << 'EOL'
    {
      "parser": "@typescript-eslint/parser",
      "plugins": ["@typescript-eslint"],
      "extends": [
        "eslint:recommended",
        "plugin:@typescript-eslint/recommended"
      ]
    }
    EOL

          echo "🎉 TypeScript project initialized! Use 'npm start' to run the project."
        fi

        export NODE_SHELL=1
        export PATH="$PWD/node_modules/.bin:$PATH"

        echo "⬢ Node.js development environment activated!"
  '';
}
