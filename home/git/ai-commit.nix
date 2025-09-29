{
  pkgs,
  ...
}: let
  ai-commit-generator = pkgs.stdenv.mkDerivation {
    pname = "ai-commit-generator";
    version = "1.0.0";

    src = pkgs.writeTextFile {
      name = "generate_commit_message.py";
      text = ''
#!/usr/bin/env python3
"""
Git commit message generator using AI models.
"""

import subprocess
import sys
import os

try:
    from transformers import AutoTokenizer, AutoModelForCausalLM
    import torch
except ImportError as e:
    print(f"Missing required package: {e}")
    sys.exit(1)

def check_git_repo():
    """Check if we're in a git repository."""
    try:
        subprocess.run(['git', 'rev-parse', '--git-dir'],
                      check=True, capture_output=True, text=True)
        return True
    except subprocess.CalledProcessError:
        return False

def get_staged_diff():
    """Get the diff of staged changes."""
    try:
        result = subprocess.run(['git', 'diff', '--cached'],
                               capture_output=True, text=True, check=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"Error getting staged changes: {e}")
        return None

def load_model():
    """Load a language model for commit message generation."""
    print("Loading model and tokenizer..." if os.getenv('AI_COMMIT_VERBOSE') else "", file=sys.stderr)

    # Use working models only
    models_to_try = [
        {
            "name": "microsoft/DialoGPT-small",
            "revision": None,
            "tokenizer": "microsoft/DialoGPT-small",
            "trust_remote_code": False,
            "add_bos_token": False
        },
        {
            "name": "gpt2",
            "revision": None,
            "tokenizer": "gpt2",
            "trust_remote_code": False,
            "add_bos_token": False
        }
    ]

    for model_config in models_to_try:
        try:
            if os.getenv('AI_COMMIT_VERBOSE'):
                print(f"Trying {model_config['name']}...", file=sys.stderr)

            tokenizer = AutoTokenizer.from_pretrained(
                model_config["tokenizer"],
                add_bos_token=model_config.get("add_bos_token", False)
            )
            # Set pad token to avoid attention mask warnings
            if tokenizer.pad_token is None:
                tokenizer.pad_token = tokenizer.eos_token

            # For models where pad_token equals eos_token, use a different pad token
            if tokenizer.pad_token_id == tokenizer.eos_token_id and hasattr(tokenizer, 'unk_token'):
                tokenizer.pad_token = tokenizer.unk_token

            load_kwargs = {
                "torch_dtype": torch.float32,
                "trust_remote_code": model_config["trust_remote_code"]
            }
            if model_config["revision"]:
                load_kwargs["revision"] = model_config["revision"]

            model = AutoModelForCausalLM.from_pretrained(
                model_config["name"],
                **load_kwargs
            )

            if os.getenv('AI_COMMIT_VERBOSE'):
                print(f"Successfully loaded {model_config['name']}", file=sys.stderr)
            return model, tokenizer, model_config['name']

        except Exception as e:
            if os.getenv('AI_COMMIT_VERBOSE'):
                print(f"Failed to load {model_config['name']}: {e}", file=sys.stderr)
            continue

    if os.getenv('AI_COMMIT_VERBOSE'):
        print("All models failed to load", file=sys.stderr)
    return None, None, None

def analyze_diff_simple(diff_text):
    """Simple heuristic analysis of git diff."""
    lines = diff_text.split('\n')
    added_files = []
    modified_files = []

    for line in lines:
        if line.startswith('+++'):
            file_path = line.split()[1]
            if file_path != '/dev/null':
                added_files.append(file_path.lstrip('b/'))
        elif line.startswith('---'):
            file_path = line.split()[1]
            if file_path != '/dev/null':
                modified_files.append(file_path.lstrip('b/'))

    # Simple commit message generation
    if added_files and not modified_files:
        if len(added_files) == 1:
            return f"Add {added_files[0]}"
        else:
            return f"Add {len(added_files)} files"
    elif modified_files and not added_files:
        if len(modified_files) == 1:
            return f"Update {modified_files[0]}"
        else:
            return f"Update {len(modified_files)} files"
    else:
        return None

def generate_commit_message(model, tokenizer, diff_text, model_name=""):
    """Generate a commit message based on the git diff."""

    # Try simple analysis first
    simple_message = analyze_diff_simple(diff_text)

    # Standard generation for models
    max_diff_length = 600
    if len(diff_text) > max_diff_length:
        diff_text = diff_text[:max_diff_length] + "..."

    prompt = f"""Write a short git commit message for:

{diff_text}

Commit:"""

    try:
        inputs = tokenizer(prompt, return_tensors="pt", truncation=True, max_length=1024, padding=True)

        # Create attention mask if not present
        if 'attention_mask' not in inputs:
            inputs['attention_mask'] = torch.ones_like(inputs['input_ids'])

        with torch.no_grad():
            # Try different generation strategies
            generation_configs = [
                {
                    "max_new_tokens": 30,
                    "temperature": 0.3,
                    "do_sample": True,
                    "pad_token_id": tokenizer.eos_token_id,
                    "eos_token_id": tokenizer.eos_token_id,
                    "repetition_penalty": 1.1
                },
                {
                    "max_new_tokens": 25,
                    "num_beams": 3,
                    "early_stopping": True,
                    "pad_token_id": tokenizer.eos_token_id,
                    "eos_token_id": tokenizer.eos_token_id
                }
            ]

            for config in generation_configs:
                try:
                    outputs = model.generate(
                        inputs.input_ids,
                        attention_mask=inputs.get('attention_mask'),
                        **config
                    )
                    generated_text = tokenizer.decode(outputs[0], skip_special_tokens=True)

                    # Extract message after prompt
                    if "Commit:" in generated_text:
                        commit_message = generated_text.split("Commit:")[-1].strip()
                    elif "Message:" in generated_text:
                        commit_message = generated_text.split("Message:")[-1].strip()
                    else:
                        # Fallback: take text after the original prompt
                        original_length = len(tokenizer.decode(inputs.input_ids[0], skip_special_tokens=True))
                        commit_message = generated_text[original_length:].strip()

                    # Clean up the message
                    commit_message = commit_message.split('\n')[0].strip()

                    if commit_message and len(commit_message) > 5:  # Valid message
                        return commit_message

                except Exception as gen_error:
                    continue

        # If all generation attempts failed, use simple analysis or basic message
        if simple_message:
            return simple_message
        return "Update files based on changes"

    except Exception as e:
        if simple_message:
            return simple_message
        return "Update files"

def main():
    if not check_git_repo():
        print("Error: Not in a git repository", file=sys.stderr)
        sys.exit(1)

    diff = get_staged_diff()
    if not diff or not diff.strip():
        print("No staged changes found. Please stage some changes first with 'git add'.", file=sys.stderr)
        sys.exit(1)

    model, tokenizer, model_name = load_model()
    if model is None or tokenizer is None:
        # Fallback to simple analysis
        simple_message = analyze_diff_simple(diff)
        if simple_message:
            print(simple_message)
        else:
            print("Update files")
        sys.exit(0)

    if os.getenv('AI_COMMIT_VERBOSE'):
        print("Generating commit message...", file=sys.stderr)
    commit_message = generate_commit_message(model, tokenizer, diff, model_name)

    if commit_message:
        print(commit_message)
    else:
        print("Update files")

if __name__ == "__main__":
    main()
      '';
    };

    nativeBuildInputs = with pkgs; [
      python3
    ];

    propagatedBuildInputs = with pkgs.python3Packages; [
      transformers
      torch
      huggingface-hub
      tokenizers
    ];

    dontUnpack = true;
    dontBuild = true;

    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/ai-commit-generate
      chmod +x $out/bin/ai-commit-generate
    '';
  };

  git-ai-script = pkgs.writeShellScriptBin "git-ai" ''
    #!/usr/bin/env bash

    # Check if we're in a git repository
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "Error: Not in a git repository" >&2
        exit 1
    fi

    # Check for staged changes
    if git diff --cached --quiet; then
        echo "No staged changes found. Please stage changes first with 'git add'." >&2
        exit 1
    fi

    # Generate commit message using AI
    COMMIT_MSG=$(${ai-commit-generator}/bin/ai-commit-generate 2>/dev/null)

    if [ $? -eq 0 ] && [ -n "$COMMIT_MSG" ]; then
        echo "Generated commit message:"
        echo "  $COMMIT_MSG"
        echo ""
        echo "To commit with this message, run:"
        echo "  git commit -m '$COMMIT_MSG'"
        echo ""
        echo "Or use: git aic"
    else
        echo "Failed to generate commit message" >&2
        exit 1
    fi
  '';

  git-aic-script = pkgs.writeShellScriptBin "git-aic" ''
    #!/usr/bin/env bash

    # Check if we're in a git repository
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "Error: Not in a git repository" >&2
        exit 1
    fi

    # Check for staged changes
    if git diff --cached --quiet; then
        echo "No staged changes found. Please stage changes first with 'git add'." >&2
        exit 1
    fi

    # Generate commit message using AI
    echo "Generating AI commit message..." >&2
    COMMIT_MSG=$(AI_COMMIT_VERBOSE=1 ${ai-commit-generator}/bin/ai-commit-generate 2>&1 | tail -n1)

    if [ $? -eq 0 ] && [ -n "$COMMIT_MSG" ]; then
        echo "Generated: $COMMIT_MSG" >&2
        git commit -m "$COMMIT_MSG"
    else
        echo "Failed to generate commit message, falling back to manual commit" >&2
        git commit
    fi
  '';
in {
  home.packages = [
    ai-commit-generator
    git-ai-script
    git-aic-script
  ];

  programs.git.aliases = {
    # AI commit aliases
    ai = "!${git-ai-script}/bin/git-ai";
    aic = "!${git-aic-script}/bin/git-aic";
  };
}